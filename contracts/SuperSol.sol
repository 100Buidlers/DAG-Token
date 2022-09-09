// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SuperSol {
    struct FunctionData {
        function(bytes memory, bytes memory, address) returns(bool) _function;
        uint256 numBytes;
    }

    mapping(bytes4 => FunctionData) _functionMap;
    mapping(bytes4 => function(bool, bool) returns (bool)) _logicalOperatorMap;
    mapping(bytes4 => function(uint256, uint256) returns (bool)) _relationalOperatorMap;

    constructor() {}

    function SuperSol_init() public {
        _functionMap[bytes4(keccak256("parenthesis"))] = FunctionData(parenthesis, 0); // entire data // f484215b
        _functionMap[bytes4(keccak256("balanceInERC721"))] = FunctionData(balanceInERC721, 20 + 4 + 32); // address + operator + threshhold
        _functionMap[bytes4(keccak256("balanceInERC1155"))] = FunctionData(balanceInERC1155, 20 + 32 + 4 + 32); // address + token Id + operator + threshhold
        _functionMap[bytes4(keccak256("balanceInERC20"))] = FunctionData(balanceInERC20, 20 + 4 + 32); // address + operator + threshhold
        _functionMap[bytes4(keccak256("verifyMerkle"))] = FunctionData(verifyMerkle, 0); // no data from cBytes only iBytes required

        _logicalOperatorMap[bytes4(keccak256("and"))] = and;
        _logicalOperatorMap[bytes4(keccak256("or"))] = or;

        _relationalOperatorMap[bytes4(keccak256("equals"))] = equals;
        _relationalOperatorMap[bytes4(keccak256("notEquals"))] = notEquals;
        _relationalOperatorMap[bytes4(keccak256("gt"))] = gt;
        _relationalOperatorMap[bytes4(keccak256("lt"))] = lt;
        _relationalOperatorMap[bytes4(keccak256("gte"))] = gte;
        _relationalOperatorMap[bytes4(keccak256("lte"))] = lte;
    }

    function parse(
        bytes memory cBytes,
        bytes memory iBytes,
        address account
    ) public returns (bool) {
        bytes4 fIdentifier = bytes4(cBytes);
        uint bytesToMove = 4 + _functionMap[fIdentifier].numBytes;
        bytes memory data = bytes.concat(bytes32(cBytes) >> (bytesToMove*8));
        _functionMap[fIdentifier]._function(data, iBytes, account);
    }

    // handler functions 
    function parenthesis(bytes memory data, bytes memory iBytes, address account) public returns(bool) {

        return false;
    }

    function balanceInERC721(bytes memory data, bytes memory iBytes, address account) public returns(bool) {
        return false;
    }

    function balanceInERC1155(bytes memory data, bytes memory iBytes, address account) public returns(bool) {
        
        return false;
    }

    function balanceInERC20(bytes memory data, bytes memory iBytes, address account) public returns(bool) {
        
        return false;
    } 


    function verifyMerkle(bytes memory data, bytes memory iBytes, address account) public returns(bool) {
        return false;
    } 




    // logical operators ====================================


    function and(bool a, bool b) public pure returns(bool) {
        return a && b;
    }


    function or(bool a, bool b) public pure returns(bool) {
        return a || b;
    }


    // relational operators ====================================

    function equals(uint256 a, uint256 b) public pure returns(bool) {
        return a == b;
    }

    function notEquals(uint256 a, uint256 b) public pure returns(bool) {
        return a != b;
    }

    function gt(uint256 a, uint256 b) public pure returns(bool) {
        return a > b;
    }

    function lt(uint256 a, uint256 b) public pure returns(bool) {
        return a < b;
    }

    function gte(uint256 a, uint256 b) public pure returns(bool) {
        return a >= b;
    }

    function lte(uint256 a, uint256 b) public pure returns(bool) {
        return a <= b;
    }
}
