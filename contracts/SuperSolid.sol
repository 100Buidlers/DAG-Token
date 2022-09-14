// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IAdapter.sol";
import "./interfaces/ISuperSolid.sol";

contract SuperSolid is Context {
    bytes4 private constant AND_IDENTIFIER = bytes4(keccak256("and"));
    bytes4 private constant OR_IDENTIFIER = bytes4(keccak256("or"));
    bytes4 private constant NAND_IDENTIFIER = bytes4(keccak256("nand"));

    address private _trustedForwarder;

    function getBytes4() public pure returns(bytes4[3] memory) {
        return [AND_IDENTIFIER, OR_IDENTIFIER, NAND_IDENTIFIER];
    }

    // mapping(bytes4 => function(bytes memory, address)
    //     returns (bool)) _functionMap;
    mapping(bytes4 => function(bool, bool)
        view
        returns (bool)) _logicalOperatorMap;

    constructor() {
        _logicalOperatorMap[AND_IDENTIFIER] = and;
        _logicalOperatorMap[OR_IDENTIFIER] = or;
        _logicalOperatorMap[NAND_IDENTIFIER] = nand;
    }

    function setTrustedForwarder(address trustedForwarder) public {
        _trustedForwarder = trustedForwarder;
    }

    function evaluate(
        bytes calldata cBytes,
        bytes calldata iBytes,
        address account
    ) public view returns (bool) {
        bool res;
        uint256 bytesUsed;
        (res, bytesUsed) = _evaluate_op(cBytes, iBytes, account);
        return res;
    }

    function _evaluate_op(bytes calldata cBytes, bytes calldata iBytes, address account)
        private
        view
        returns (bool, uint256)
    {
        bytes4 opIdentifier = bytes4(cBytes[:4]);
        bytes4 nextidentifier;

        // evaluation ltree
        bool ltreeRes;
        uint256 startLtree = 4;
        uint256 ltreeBytesUsed;
        nextidentifier = bytes4(cBytes[startLtree:]);
        if (
            (nextidentifier == AND_IDENTIFIER) ||
            (nextidentifier == OR_IDENTIFIER) ||
            (nextidentifier == NAND_IDENTIFIER)
        ) {
            (ltreeRes, ltreeBytesUsed) = _evaluate_op(
                cBytes[startLtree:],
                iBytes,
                account
            );
        } else {
            (ltreeRes, ltreeBytesUsed) = _evaluate_adapter(cBytes[startLtree:], account);
        }

        // evaluation rtree
        bool rtreeRes;
        uint256 startRtreeRes = startLtree + ltreeBytesUsed;
        uint256 rtreeBytesUsed;
        nextidentifier = bytes4(cBytes[startRtreeRes:]);
        if (
            (nextidentifier == AND_IDENTIFIER) ||
            (nextidentifier == OR_IDENTIFIER) ||
            (nextidentifier == NAND_IDENTIFIER)
        ) {
            (rtreeRes, rtreeBytesUsed) = _evaluate_op(
                cBytes[startRtreeRes:],
                iBytes,
                account
            );
        } else {
            (rtreeRes, rtreeBytesUsed) = _evaluate_adapter(
                cBytes[startRtreeRes:], account
            );
        }
        return (
            _logicalOperatorMap[opIdentifier](ltreeRes, rtreeRes),
            ltreeBytesUsed + rtreeBytesUsed
        );
    }

    function _evaluate_adapter(bytes calldata cBytes, address account)
        private
        view
        returns (bool, uint256)
    {
        address adapterAddress;
        bytes memory aBytes;
        adapterAddress = address(bytes20(cBytes));
        uint256 bytesToMove = IAdapter(adapterAddress).getBytes();

        uint256 end = 20 + bytesToMove;
        aBytes = cBytes[20:end];

        return (IAdapter(adapterAddress).evaluate(aBytes, account), end);
    }

    // function mergeBytes(bytes memory a, bytes20 b)
    //     public
    //     pure
    //     returns (bytes memory c)
    // {
    //     // Store the length of the first array
    //     uint256 alen = a.length;
    //     // Store the length of BOTH arrays
    //     uint256 totallen = alen + b.length;
    //     // Count the loops required for array a (sets of 32 bytes)
    //     uint256 loopsa = (a.length + 31) / 32;
    //     // Count the loops required for array b (sets of 32 bytes)
    //     uint256 loopsb = (b.length + 31) / 32;
    //     assembly {
    //         let m := mload(0x40)
    //         // Load the length of both arrays to the head of the new bytes array
    //         mstore(m, totallen)
    //         // Add the contents of a to the array
    //         for {
    //             let i := 0
    //         } lt(i, loopsa) {
    //             i := add(1, i)
    //         } {
    //             mstore(
    //                 add(m, mul(32, add(1, i))),
    //                 mload(add(a, mul(32, add(1, i))))
    //             )
    //         }
    //         // Add the contents of b to the array
    //         for {
    //             let i := 0
    //         } lt(i, loopsb) {
    //             i := add(1, i)
    //         } {
    //             mstore(
    //                 add(m, add(mul(32, add(1, i)), alen)),
    //                 mload(add(b, mul(32, add(1, i))))
    //             )
    //         }
    //         mstore(0x40, add(m, add(32, totallen)))
    //         c := m
    //     }
    // }

    // logical operators ====================================
    function and(bool a, bool b) private pure returns (bool) {
        return a && b;
    }

    function or(bool a, bool b) private pure returns (bool) {
        return a || b;
    }

    function nand(bool a, bool b) private pure returns (bool) {
        return !(a && b);
    }

    function _msgSender()
        internal
        view
        override(Context)
        returns (address sender)
    {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function isTrustedForwarder(address forwarder)
        public
        view
        virtual
        returns (bool)
    {
        return forwarder == _trustedForwarder;
    }
}
