// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


interface IREP3Token {
    function balanceOf(address) external view returns (uint256);

    function membershipExists(address, uint16) external view returns(bool)
}