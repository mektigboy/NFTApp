const { ethers } = require("hardhat");

module.exports = async function (hre) {
    const { getNamedAccounts, deployments } = hre;
    const { deployer } = await getNamedAccounts();
    const random = await ethers.getContract("Random", deployer);
    const mintTx = await random.requestObject();
    const mintTxReceipt = await mintTx.wait(1);
};

module.exports.tags = ["all", "mint"];
