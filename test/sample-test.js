const { expect } = require("chai");
const { ethers } = require("hardhat");
const LendingPoolV2Artifact = require('@aave/protocol-v2/artifacts/contracts/protocol/lendingpool/LendingPool.sol/LendingPool.json');
const IERC20Artifact = require('@openzeppelin/contracts/build/contracts/IERC20.json');


describe("Token21", function() {
  it("Token functionalities", async function() {
    const Token21 = await ethers.getContractFactory("Token21");
    const token21 = await Token21.deploy(100000);
    
    await token21.deployed();

    // 
    const [owner, addr1, addr2] = await ethers.getSigners();
    // console.log(owner, addr1);
    // console.log(await token21.totalSupply());
    // console.log(await token21.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"));
    await token21.transfer(addr1.address, 50);
    await token21.connect(addr1).transfer( addr2.address, 10);

    expect(await token21.balanceOf(addr1.address)).to.equal(40);
    expect(await token21.balanceOf(addr2.address)).to.equal(10);

    // await token21.setGreeting("Hola, mundo!");
    // expect(await token21.greet()).to.equal("Hola, mundo!");
  });
});


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
    // // // create dai object and approve for address
    await chitFund.connect(signer)._deposit(amount);
    const balanceAfter = await dai.balanceOf(impersonateAccount);
    console.log(balanceAfter.toString());
  });
});