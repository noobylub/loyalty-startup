require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  //sample just for trial 
  defaultNetwork : "hardhat",
  
  networks : {
    hardhat : {
      chainId : 1337
    }
  },



  solidity: {
    version : "0.8.9", 
    allowUnlimitedContractSize: true,
    settings : {
      optimizer : {
        enabled : true, 
        runs : 1000
      }
    }
  }
};