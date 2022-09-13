// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../interfaces/IAdapter.sol";
import "./coreAdapter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC721BalanceThreshold is IAdapter {
    RelationalOperatorAdapter private _relOpAdapter;

    constructor(address relOpAddress) {
        _relOpAdapter = RelationalOperatorAdapter(address(relOpAddress));
    }

    function getBytes() public pure returns (uint256) {
        // 20 bytes for erc 721 address
        // 4 bytes for relational operator.. can be == != > < >= <=
        // 32 bytes for threshold

        // eg check if account has >= 5 bored apes
        return 20 + 4 + 32;
    }

    function evaluate(bytes memory data) public view returns (bool) {
        address account;
        assembly {
            account := shr(96, calldataload(sub(calldatasize(), 20)))
        }
        address contractAddress = address(bytes20(data));
        uint256 balance = IERC721(contractAddress).balanceOf(account);
        bytes4 rIdentifier;
        uint256 threshold;
        assembly {
            rIdentifier := calldataload(4)
            threshold := calldataload(24)
        }
        return _relOpAdapter.evaluate(rIdentifier, balance, threshold);
    }
}
