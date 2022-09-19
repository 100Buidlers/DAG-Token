// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../interfaces/IAdapter.sol";
import "../../interfaces/ILensHub.sol";
import "../../interfaces/IFollowNFT.sol";
import "../coreAdapter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract LensIfFollower is IAdapter {
    RelationalOperatorAdapter private _relOpAdapter;
    address private lensHubAddress;

    constructor(address _lensHubAddress) {
        lensHubAddress = _lensHubAddress;
    }

    function getBytes() public pure returns (uint256) {
        // 32 bytes for profile id
        return 32;
    }

    function evaluate(bytes calldata data, address account) public view returns (bool) {
        uint256 defaultProfile = ILensHub(lensHubAddress).defaultProfile(account);
        if (defaultProfile == 0) {
            return false;
        }
        uint256 profileId = uint256(bytes32(data[0:32]));
        address followNFT = ILensHub(lensHubAddress).getFollowNFT(profileId);
        uint256 followNFTBalance = IFollowNFT(followNFT).balanceOf(account);
        return followNFTBalance > 0;
    }
}