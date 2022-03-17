const XYZToken = artifacts.require("XYZToken");
const XYZTokenSale = artifacts.require("XYZTokenSale");

require("dotenv").config({path:"../.env"});

module.exports = async function (deployer) {
    const accounts = await web3.eth.getAccounts();
    await deployer.deploy(XYZToken,"XYZToken","XYZ",process.env.INITIAL_SUPPLY);
    const tokenInstance = await XYZToken.deployed();
    const totalTokenSupplied = await tokenInstance.balanceOf(accounts[0]);
    await deployer.deploy(XYZTokenSale,XYZToken.address);
    await tokenInstance.transfer(XYZTokenSale.address,totalTokenSupplied);
    const tokenForSale = await tokenInstance.balanceOf(XYZTokenSale.address);
    // console.log(tokenForSale.toString());
};
