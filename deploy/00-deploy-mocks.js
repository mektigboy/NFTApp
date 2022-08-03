const { network } = require("hardhat");

const BASE_FEE = "250000000000000000" // 0.25 ETH
const GAS_PRICE_LINK = 1e9;

module.exports = async function (hre) {
    const { getNamedAccounts, deployments } = hre;
    const { deployer } = await getNamedAccounts();
    const { deploy, log } = deployments;
    const chainId = network.config.chainId;

    if (chainId == 31337) {
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: [BASE_FEE, GAS_PRICE_LINK],
        });
    }
};

module.exports.tags = ["all", "mocks"];
