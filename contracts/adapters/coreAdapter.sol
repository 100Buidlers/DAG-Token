// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RelationalOperatorAdapter {
    mapping(bytes4 => function(uint256, uint256) pure returns (bool)) private _relationalOperatorMap;

    constructor() {
        _relationalOperatorMap[bytes4(keccak256("equals"))] = equals;
        _relationalOperatorMap[bytes4(keccak256("notEquals"))] = notEquals;
        _relationalOperatorMap[bytes4(keccak256("gt"))] = gt;
        _relationalOperatorMap[bytes4(keccak256("lt"))] = lt;
        _relationalOperatorMap[bytes4(keccak256("gte"))] = gte;
        _relationalOperatorMap[bytes4(keccak256("lte"))] = lte;
    }

    function evaluate(bytes4 fIdentifier, uint256 a, uint256 b) public view returns(bool){
        return _relationalOperatorMap[fIdentifier](a, b);
    }

    function equals(uint256 a, uint256 b) internal pure returns(bool) {
        return a == b;
    }

    function notEquals(uint256 a, uint256 b) internal pure returns(bool) {
        return a != b;
    }

    function gt(uint256 a, uint256 b) internal pure returns(bool) {
        return a > b;
    }

    function lt(uint256 a, uint256 b) internal pure returns(bool) {
        return a < b;
    }

    function gte(uint256 a, uint256 b) internal pure returns(bool) {
        return a >= b;
    }

    function lte(uint256 a, uint256 b) internal pure returns(bool) {
        return a <= b;
    }
}