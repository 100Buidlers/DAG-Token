// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../interfaces/IAdapter.sol";
import "../../interfaces/ILensHub.sol";
import "../coreAdapter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract LensProfileExists is IAdapter {
    address private lensHubAddress;
    RelationalOperatorAdapter private _relOpAdapter;

    constructor(address relOpAddress, address _lensHubAddress) {
        lensHubAddress = _lensHubAddress;
        _relOpAdapter = RelationalOperatorAdapter(address(relOpAddress));
    }

    function getBytes() public pure returns (uint256) {
        return 0;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        uint256 balance = ILensHub(lensHubAddress).balanceOf(account);
        bytes4 rIdentifier = bytes4(keccak256("equals"));
        uint256 threshold = 1;
        return _relOpAdapter.evaluate(rIdentifier, balance, threshold);
    }
}