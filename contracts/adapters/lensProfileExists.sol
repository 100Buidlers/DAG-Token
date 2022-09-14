// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../interfaces/IAdapter.sol";
import "./coreAdapter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILensHub {
    function owner(address) external view returns(uint256);
}

contract LensProfileExists is IAdapter {
    RelationalOperatorAdapter private _relOpAdapter;

    constructor(address relOpAddress) {
        _relOpAdapter = RelationalOperatorAdapter(address(relOpAddress));
    }

    function getBytes() public pure returns (uint256) {
        return 0;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        address lensHub = 0xBf8781cA02A58CBad4870F6604a444dfA938203c;
        uint256 balance = ILensHub(lensHub).owner(account);
        bytes4 rIdentifier = bytes4(keccak256("equals"));
        uint256 threshold = 1;
        return _relOpAdapter.evaluate(rIdentifier, balance, threshold);
    }
}