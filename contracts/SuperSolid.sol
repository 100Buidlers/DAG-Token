// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";


import "./interfaces/IAdapter.sol";
import "./interfaces/ISuperSolid.sol";

contract SuperSolid is Context, ISuperSolid {
    bytes4 private constant AND_IDENTIFIER = bytes4(keccak256("and"));
    bytes4 private constant OR_IDENTIFIER = bytes4(keccak256("or"));
    bytes4 private constant NAND_IDENTIFIER = bytes4(keccak256("nand"));

    address private _trustedForwarder;

    // mapping(bytes4 => function(bytes memory, address)
    //     returns (bool)) _functionMap;
    mapping(bytes4 => function(bool, bool)
        view
        returns (bool)) _logicalOperatorMap;

    constructor() {}

    function setTrustedForwarder(address trustedForwarder) public {
        _trustedForwarder = trustedForwarder;
    }

    function SuperSol_init() public {
        _logicalOperatorMap[AND_IDENTIFIER] = and;
        _logicalOperatorMap[OR_IDENTIFIER] = or;
        _logicalOperatorMap[NAND_IDENTIFIER] = nand;
    }

    // last parameter should be account address
    function evaluate(bytes calldata cBytes, bytes calldata iBytes, address account)
        public
        view
        returns (bool)
    {
        bool res;
        uint256 bytesUsed;
        (res, bytesUsed) = _evaluate_op(cBytes, iBytes);
        return res;
    }

    function _evaluate_op(bytes calldata cBytes, bytes calldata iBytes)
        private
        view
        returns (bool, uint256)
    {
        bytes4 opIdentifier;
        bytes4 nextidentifier;

        assembly {
            opIdentifier := calldataload(0)
        }

        // evaluation ltree
        bool ltreeRes;
        uint256 startLtree = 20;
        uint256 ltreeBytesUsed;
        assembly {
            nextidentifier := calldataload(startLtree)
        }
        if (
            (nextidentifier == AND_IDENTIFIER) ||
            (nextidentifier == OR_IDENTIFIER) ||
            (nextidentifier == NAND_IDENTIFIER)
        ) {
            (ltreeRes, ltreeBytesUsed) = _evaluate_op(
                cBytes[startLtree:],
                iBytes
            );
        } else {
            (ltreeRes, ltreeBytesUsed) = _evaluate_adapter(cBytes[startLtree:]);
        }

        // evaluation rtree
        bool rtreeRes;
        uint256 startRtreeRes = startLtree + ltreeBytesUsed;
        uint256 rtreeBytesUsed;
        assembly {
            nextidentifier := calldataload(startRtreeRes)
        }
        if (
            (nextidentifier == AND_IDENTIFIER) ||
            (nextidentifier == OR_IDENTIFIER) ||
            (nextidentifier == NAND_IDENTIFIER)
        ) {
            (rtreeRes, rtreeBytesUsed) = _evaluate_op(
                cBytes[startRtreeRes:],
                iBytes
            );
        } else {
            (rtreeRes, rtreeBytesUsed) = _evaluate_adapter(
                cBytes[startRtreeRes:]
            );
        }
        return (
            _logicalOperatorMap[opIdentifier](ltreeRes, rtreeRes),
            ltreeBytesUsed + rtreeBytesUsed
        );
    }

    function _evaluate_adapter(bytes calldata cBytes)
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
        aBytes = abi.encodePacked(aBytes, _msgSender());
        return (IAdapter(adapterAddress).evaluate(aBytes), end);
    }

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
