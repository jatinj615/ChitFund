const { expect } = require("chai");
const { ethers } = require("hardhat");

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

    const abi = [
      // View functions 
      "function totalSupply() external view returns (uint256)", 
      "function balanceOf(address account) external view returns (uint256)",
      "function allowance(address owner, address spender) external view returns (uint256)",
      // Authenticated functions
      "function transfer(address recipient, uint256 amount) external returns (bool)",
      "function approve(address spender, uint256 amount) external returns (bool)",
      "function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)",
      // events
      "event Transfer(address indexed from, address indexed to, uint256 value)",
      "event Approval(address indexed owner, address indexed spender, uint256 value)"
    ]
    const daiAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const provider = await ethers.getDefaultProvider();

    const dai = await new ethers.Contract(daiAddress, abi, provider);
    await chitFund.deployed();
    
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x9e033f4d440c4e387ed87759cb4436c7a95c45a3"]}
    )

    signer = ethers.provider.getSigner("0x9e033f4d440c4e387ed87759cb4436c7a95c45a3");
    
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log(await dai.balanceOf(addr1.address));
    // await dai.connect(addr1.address).approve(chitFund.address, 500);
    // create dai object and approve for address
    // await chitFund.connect(addr1.address)._approve(chitFund.address, 50);
    // dai account =  0x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503
    // await chitFund.dai.approve(chitFund)
    // await chitFund.connect(addr1)._deposit(500);
  });
});