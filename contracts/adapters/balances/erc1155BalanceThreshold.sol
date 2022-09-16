// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../../interfaces/IAdapter.sol";
import "../coreAdapter.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract ERC1155BalanceThreshold is IAdapter {
    RelationalOperatorAdapter private _relOpAdapter;

    constructor(address relOpAddress) {
        _relOpAdapter = RelationalOperatorAdapter(address(relOpAddress));
    }

    function getBytes() public pure returns (uint256) {
        // 20 bytes for erc 1155 address
        // 32 bytes for token Id
        // 4 bytes for relational operator.. can be == != > < >= <=
        // 32 bytes for threshold

        // eg check if account has >= 5 nfts of tokens id 1
        return 20 + 32 + 4 + 32;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        address contractAddress = address(bytes20(data));
        uint256 tokenId = uint256(bytes32(data[20: 52]));
        uint256 balance = IERC1155(contractAddress).balanceOf(account, tokenId);
        bytes4 rIdentifier = bytes4(data[52:56]);
        uint256 threshold = uint256(bytes32(data[56:]));
        return _relOpAdapter.evaluate(rIdentifier, balance, threshold);
    }
}
