// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../interfaces/IAdapter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract Rep3MembershipExists is IAdapter {

    constructor() {}

    function getBytes() public pure returns (uint256) {
        // 20 contract address
        return 20;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        address rep3TokenAddress = address(bytes20(data[:20]));
        uint256 balance = IERC721(rep3TokenAddress).balanceOf(account);
        return balance > 0;
    }
}