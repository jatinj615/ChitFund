// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import {ILendingPoolAddressesProvider} from "@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import {ILendingPool} from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
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
    
    // datetime interface 
    address dtAddress = 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce;
    DateTimeInterface dateTime = DateTimeInterface(dtAddress);
    
    // deposit start date and end date
    uint8 depositStartDate = 1;
    uint8 depositEndDate = 5;
    
    struct Member {
      uint256 value;
    }

    mapping (address => Member) ownerInfo;
    
    modifier depositDate() {
        require(dateTime.getDay(block.timestamp) >= depositStartDate && dateTime.getDay(block.timestamp) <= depositEndDate);
        _;
    }
    
    modifier minDeposit(uint256 _amount) {
        require(_amount >= 1 , "Minimum Deposit amount is $500");
        _;
    }
    
    function _approve(address _spender, uint256 _amount) public returns (bool) {
        dai.approve(_spender, _amount);
        return true;
    }
    
    
    function _deposit(uint256 _amount) public minDeposit(_amount) returns(uint) {
        Member storage user = ownerInfo[msg.sender];
        dai.transferFrom(msg.sender, address(this), _amount);
        user.value += _amount;
        dai.approve(lpAddress, _amount);
        lendingPool.deposit(daiAddress, _amount, msg.sender, 0);
        return address(this).balance;
    }
    
    function _claim() public {
        Member memory user = ownerInfo[msg.sender];
        require (user.value > 0, "Cannot claim, Empty Balance!");
        address payable receiver = payable(msg.sender);
        receiver.transfer(user.value);
    }
}
