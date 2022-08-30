require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  //sample just for trial 
  defaultNetwork : "hardhat",
  //allowUnlimitedContractSize: true,
  networks : {
    hardhat : {
      chainId : 1337
    }
  },



  solidity: {
    version : "0.8.9", 
    settings : {
      optimizer : {
        enabled : true, 
        runs : 1000
      }
    }
  }
};