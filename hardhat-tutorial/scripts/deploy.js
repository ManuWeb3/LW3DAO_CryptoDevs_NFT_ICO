const { ethers } = require("hardhat");
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS  } = require("../constants")
const {network} = require("hardhat")
const {developmentChains} = require("../helper-hardhat-config.js")
const {verify} = require("../utils/verify")

async function main() {
    // Address of the Crypto Devs NFT contract that you deployed in the previous module
    const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;
    
    console.log("Deploying CryptoDevToken...")
    const cryptoDevsTokenFactory = await ethers.getContractFactory("CryptoDevToken")

    const deployedCryptoDevsTokenContract = await cryptoDevsTokenFactory.deploy(
      cryptoDevsNFTContract        
    )

    await deployedCryptoDevsTokenContract.deployTransaction.wait(10)
    // instead of .deployed()

    console.log(`CryptoDevsToken Address: ${deployedCryptoDevsTokenContract.address}`)
    console.log("------------------------")
    
    //  2. Verify on Etherscan, if it's Goerli
    const args = [cryptoDevsNFTContract]

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
      console.log("Verifying on GoerliEtherscan...")
      await verify(deployedCryptoDevsTokenContract.address, args)
      //  it takes address and args of the S/C as parameters
      console.log("-------------------------------")
    }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });