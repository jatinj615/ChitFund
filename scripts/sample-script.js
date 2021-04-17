// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ChitFund = await hre.ethers.getContractFactory("ChitFund");
  const chitFund = await ChitFund.deploy();

  const Token21 = await hre.ethers.getContractFactory("Token21");
  const token21 = await Token21.deploy(100000);

  await chitFund.deployed();
  await token21.deployed();

  console.log("ChitFund deployed to:", chitFund.address);
  console.log("Token21 deployed to:", token21.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
