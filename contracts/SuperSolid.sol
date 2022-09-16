// SPDX-License-Identifier: MIT
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
        // uint256 newLevel = level + 1;
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
        uint256 startRtreeRes = startLtree + ltreeBytesUsed;
        bool rtreeRes;
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
            4 + ltreeBytesUsed + rtreeBytesUsed
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
}
