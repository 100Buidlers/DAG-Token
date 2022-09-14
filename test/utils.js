const { ethers, upgrades, deployments } = require("hardhat");
const { assert, expect } = require("chai");

async function deployContracts() {
    const nullAddress = ethers.utils.getAddress("0x0000000000000000000000000000000000000000");

    const relationalOperatorAdapterContract = await ethers.getContractFactory("RelationalOperatorAdapter");
    relationalOperatorAdapter = await relationalOperatorAdapterContract.deploy();
    console.log(`deployed relationalOperatorAdapter contract ${relationalOperatorAdapter.address}`);

    const erc721BalanceThresholdContract = await ethers.getContractFactory("ERC721BalanceThreshold");
    erc721BalanceThreshold = await erc721BalanceThresholdContract.deploy(relationalOperatorAdapter.address);
    console.log(`deployed erc721BalanceThreshold contract ${erc721BalanceThreshold.address}`);

    const superSolidContract = await ethers.getContractFactory("SuperSolid");
    superSolid = await superSolidContract.deploy();
    console.log(`deployed superSolid contract ${superSolid.address}`);

    const activityTokenContract = await ethers.getContractFactory("ActivityToken");
    activitytoken = await activityTokenContract.deploy(superSolid.address);
    console.log(`deployed activityToken contract ${activitytoken.address}`);
    
    return [nullAddress, relationalOperatorAdapter, erc721BalanceThreshold, superSolid, activitytoken]
}

async function deployTestERC721(){
    const testERC721Contract = await ethers.getContractFactory("TestERC721");
    testERC721 = await testERC721Contract.deploy("Test", "TST");
    console.log(`deployed testERC721 contract ${testERC721.address}`);
    return [testERC721]
}

module.exports = {
    deployContracts,
    deployTestERC721,
}