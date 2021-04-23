const { expect } = require("chai");
const { ethers } = require("hardhat");
const LendingPoolV2Artifact = require('@aave/protocol-v2/artifacts/contracts/protocol/lendingpool/LendingPool.sol/LendingPool.json');
const IERC20Artifact = require('@openzeppelin/contracts/build/contracts/IERC20.json');


describe("ChitFund", function() {
  it("ChitFund functionalities", async function() {
    const ChitFund = await ethers.getContractFactory("ChitFund");
    const chitFund = await ChitFund.deploy();
    // console.log(lendingPoolAbi);
    const ierc20Abi = IERC20Artifact.abi;

    // console.log(IERC20Artifact);
    const impersonateAccount = "0x9e033f4d440c4e387ed87759cb4436c7a95c45a3"
    const daiAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const provider = ethers.getDefaultProvider();
    const amount = ethers.utils.parseEther("500");
    const less_amount = ethers.utils.parseEther("200");
    // console.log(amount.toString());
    await chitFund.deployed();
    
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x9e033f4d440c4e387ed87759cb4436c7a95c45a3"]}
      )
    
    signer = ethers.provider.getSigner(impersonateAccount);
    const dai = new ethers.Contract(daiAddress, ierc20Abi, signer);
    const [owner, addr1, addr2] = await ethers.getSigners();
    
    const balanceBefore = await dai.balanceOf(impersonateAccount);
    console.log(balanceBefore.toString());
    await dai.connect(signer).approve(chitFund.address, amount);
    // create dai object and approve for address
    await chitFund.connect(signer)._deposit(amount);
    const balanceAfter = await dai.balanceOf(impersonateAccount);
    console.log(balanceAfter.toString());

    // claim total amount
    await chitFund.connect(signer)._claim();
    const balanceAfterClaim = await dai.balanceOf(impersonateAccount);
    const cont_bal = await dai.balanceOf(chitFund.address);
    // console.log(cont_bal.toString());
    console.log(balanceAfterClaim.toString());
  });
});