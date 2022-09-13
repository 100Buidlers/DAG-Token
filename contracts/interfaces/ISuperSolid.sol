// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ISuperSolid {
    function evaluate(bytes calldata cBytes, bytes calldata iBytes, address account)
        external
        view
        returns (bool);
}
