// Fetch the contract data from the json files
var pp_token = artifacts.require("./ppToken.sol");
var pp_dex = artifacts.require("ppSwapExchangeCreator");


// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.deploy(pp_token, 123456789);
    deployer.deploy(pp_dex);
}