const { ethers, upgrades, deployments } = require("hardhat");
const { assert, expect } = require("chai");

async function deployContracts() {
    const nullAddress = ethers.utils.getAddress("0x0000000000000000000000000000000000000000");
    const activityTokenContract = await ethers.getContractFactory("ActivityToken");
    activitytoken = await activityTokenContract.deploy();
    console.log("deployed activity token");

    // const routerContract = await ethers.getContractFactory("Router");
    // router = await routerContract.deploy(manager.address, nullAddress);
    // console.log("dispatcher deployed");

    // const rep3TokenContract = await ethers.getContractFactory("REP3Token");
    // rep3Singleton = await rep3TokenContract.deploy();
    // console.log("deployed rep3Singleton");

    // const upgradeableBeaconContract = await ethers.getContractFactory("UpgradeableBeacon");
    // upgradeableBeacon = await upgradeableBeaconContract.deploy(rep3Singleton.address);
    // console.log("deployed upgradeable beacon");

    // signers = await ethers.getSigners(); 
    // const owner = signers[0];

    // let managerNonce = await ethers.provider.getTransactionCount(manager.address);
    // const proxyAddress = ethers.utils.getContractAddress({ from: manager.address, nonce: managerNonce });
    // await expect(
    //     manager.deployREP3TokenProxy("Test", "TST", [owner.address], upgradeableBeacon.address, router.address)
    // ).to.emit(manager, "ProxyDeployed").withArgs(proxyAddress, "Test");
    // rep3BeaconProxy = rep3Singleton.attach(proxyAddress);
    // console.log("deployed beacon proxy");
    
    return [nullAddress, activitytoken]
}

module.exports = {
    deployContracts
}