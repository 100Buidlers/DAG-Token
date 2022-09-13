// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


interface IAdapter {
    function getBytes() external pure returns(uint256);
    function evaluate(bytes memory data) external view returns(bool); 
}