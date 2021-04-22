// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import {ILendingPoolAddressesProvider} from "@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import {ILendingPool} from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import "hardhat/console.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20} from "./IERC20.sol";

 
interface DateTimeInterface {
    function getDay(uint timestamp) external pure returns (uint8);
}

contract ChitFund {
    
    // Lending Pool configuration
    address lendingPoolAddressesProvider = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;
    ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(lendingPoolAddressesProvider);
    address lpAddress = provider.getLendingPool();
    ILendingPool lendingPool = ILendingPool(lpAddress);

    address daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IERC20 dai = IERC20(daiAddress);
    IERC20 aDai = IERC20(0x028171bCA77440897B824Ca71D1c56caC55b68A3);
    
    // datetime interface 
    address dtAddress = 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce;
    DateTimeInterface dateTime = DateTimeInterface(dtAddress);
    
    // chitfund data
    uint8 depositStartDate = 1;
    uint8 depositEndDate = 5;
    uint16 claimDate = 30;
    // chitfund tracking variables
    uint256 totalDeposit;
    bool claimed = false;

    struct Member {
      uint256 value;
    }

    mapping (address => Member) ownerInfo;
    
    modifier depositDate() {
        require(dateTime.getDay(block.timestamp) >= depositStartDate && dateTime.getDay(block.timestamp) <= depositEndDate);
        _;
    }
    
    modifier minDeposit(uint256 _amount) {
        require(_amount >= 500 , "Minimum Deposit amount is $500");
        _;
    }

    modifier withdrawDate() {
      require(dateTime.getDay(block.timestamp) == claimDate);
      _;
    }
    
    function _approve(address _spender, uint256 _amount) public returns (bool) {
        dai.approve(_spender, _amount);
        return true;
    }
    
    
    function _deposit(uint256 _amount) public minDeposit(_amount) returns(uint) {
        // reset ChitFund tracking variables
        if (claimed == true) {
          claimed = false;
        }
        Member storage user = ownerInfo[msg.sender];
        dai.transferFrom(msg.sender, address(this), _amount);
        user.value += _amount;
        totalDeposit += _amount;
        dai.approve(lpAddress, _amount);
        lendingPool.deposit(daiAddress, _amount, address(this), 0);
        return address(this).balance;
    }
    
    function _claim() public {
        uint256 _amount;
        Member storage user = ownerInfo[msg.sender];
        require (user.value > 0, "Cannot claim, Empty Balance!");

        // withdraw from lending pool
        // send interest to first claimer
        if(claimed == false) {
          console.log("allowance - ", aDai.allowance(address(this), lpAddress));
          uint256 amountWithdrawn = lendingPool.withdraw(daiAddress, type(uint256).max, address(this));
          _amount = user.value + (amountWithdrawn - totalDeposit);
          totalDeposit = 0;
          user.value = 0;
          claimed = true;
        } else {
          _amount = user.value;
          user.value = 0;
        }
        // Transfer to user
        dai.transfer(msg.sender, _amount);
    }
}
