// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../../interfaces/IAdapter.sol";
import "../coreAdapter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20BalanceThreshold is IAdapter {
    RelationalOperatorAdapter private _relOpAdapter;

    constructor(address relOpAddress) {
        _relOpAdapter = RelationalOperatorAdapter(address(relOpAddress));
    }

    function getBytes() public pure returns (uint256) {
        // 20 bytes for erc 20 address
        // 4 bytes for relational operator.. can be == != > < >= <=
        // 32 bytes for threshold

        // eg check if account has >= 5 BANK tokens
        return 20 + 4 + 32;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        address contractAddress = address(bytes20(data));
        uint256 balance = IERC20(contractAddress).balanceOf(account);
        bytes4 rIdentifier = bytes4(data[20:24]);
        uint256 threshold = uint256(bytes32(data[24:]));
        return _relOpAdapter.evaluate(rIdentifier, balance, threshold);
    }
}
