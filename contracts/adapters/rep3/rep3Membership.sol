// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

// import "../../interfaces/IAdapter.sol";
// import "../../interfaces/ILensHub.sol";
// import "../../interfaces/IFollowNFT.sol";
// import "../coreAdapter.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


// contract Rep3MembershipExists is IAdapter {
//     RelationalOperatorAdapter private _relOpAdapter;

//     constructor(address relOpAddress) {
//         _relOpAdapter = RelationalOperatorAdapter(address(relOpAddress));
//     }

//     function getBytes() public pure returns (uint256) {
//         // 20 contract address
//         // 2 levelCategory
//         return 36;
//     }

//     function evaluate(bytes calldata data, address account) public view returns (bool) {
//         uint256 defaultProfile = ILensHub(lensHubAddress).defaultProfile(account);
//         if (defaultProfile == 0) {
//             return false;
//         }
//         uint256 pubCount = ILensHub(lensHubAddress).getPubCount(defaultProfile);
//         bytes4 rIdentifier = bytes4(data[0:4]);
//         uint256 threshold = uint256(bytes32(data[4:36]));
//         return _relOpAdapter.evaluate(rIdentifier, pubCount, threshold);
//     }
// }