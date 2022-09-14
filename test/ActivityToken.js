const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployContracts, deployTestERC721 } = require('./utils');
const { getBytes4HexKeccack, TreeNode, encodeConditions } = require("./encoder")

const defaultAbiCoder = ethers.utils.defaultAbiCoder;


describe("ActivityToken", function () {
  let nullAddress;
  let relationalOperatorAdapter;
  let erc721BalanceThreshold;
  let superSolid;
  let activitytoken;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [nullAddress, relationalOperatorAdapter, erc721BalanceThreshold, superSolid, activitytoken] = await deployContracts();
    [owner, addr1, addr2] = await ethers.getSigners();
    console.log(owner.address, addr1.address, addr2.address);
  });

  describe("activity token tests", function () {
    it("Should deploy the contracts", async function () {
      expect(await activitytoken.superSolidAddress()).to.equal(superSolid.address);
    });

    it("Should setup tokenId 0", async function () {
      // deploy the test erc721 contract
      let testERC721a;
      let testERC721b;
      [testERC721a] = await deployTestERC721();
      [testERC721b] = await deployTestERC721();
      await expect(
        testERC721a.mint()).to.emit(testERC721a, "Transfer").withArgs(nullAddress, owner.address, 0);
      await expect(
        testERC721b.mint()).to.emit(testERC721b, "Transfer").withArgs(nullAddress, owner.address, 0);

      let node1 = new TreeNode(
        [erc721BalanceThreshold.address.slice(2), testERC721a.address.slice(2), getBytes4HexKeccack("gt"), defaultAbiCoder.encode(["uint256"], [0]).slice(2)],
        false,
        "ERC721BalanceThreshold"
      )
      console.log(node1.data);

      let node2 = new TreeNode(
        [erc721BalanceThreshold.address.slice(2), testERC721b.address.slice(2), getBytes4HexKeccack("gt"), defaultAbiCoder.encode(["uint256"], [0]).slice(2)],
        false,
        "ERC721BalanceThreshold"
      )
      console.log(node2.data);

      let node3 = new TreeNode(
        [getBytes4HexKeccack("and")],
        true,
        "and"
      )
      console.log(node3.data);

      node3.set_left(node1)
      node3.set_right(node2)
      bytes = encodeConditions(node3);

      expect(await activitytoken.superSolidAddress()).to.equal(superSolid.address);
      await expect(
        activitytoken.setup(0, bytes)).to.emit(activitytoken, "SetupEvent").withArgs(0, bytes);

      console.log(await activitytoken.checkValidity(0, 0));
    })
  });
});
