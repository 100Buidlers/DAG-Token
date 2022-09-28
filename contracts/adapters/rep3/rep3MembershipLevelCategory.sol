// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../interfaces/IAdapter.sol";
import "../../interfaces/IREP3Token.sol";


contract Rep3MembershipExists is IAdapter {

    constructor() {}

    function getBytes() public pure returns (uint256) {
        // 20 contract address
        // 2 levelCategory
        return 22;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        address rep3TokenAddress = address(bytes20(data[:20]));
        uint26 levelCategory = uint16(bytes2(data[20:22]));
        return IREP3Token(rep3TokenAddress).membershipExists(account, levelCategory);
    }
}