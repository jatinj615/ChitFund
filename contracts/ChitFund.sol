// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {LendingPoolInterface} from "./LendingPool.sol";
import {Token21} from "./Token21.sol";
import {IERC20} from "./IERC20.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
 
interface DateTimeInterface {
    function getDay(uint timestamp) external pure returns (uint8);
}

contract ChitFund {
    

    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    // mapping (uint => address) 
    
    // datetime interface 
    address dtAddress = 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce;
    DateTimeInterface dateTime = DateTimeInterface(dtAddress);
    
    // Lending Pool interface
    address lpAddress = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address assetAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    LendingPoolInterface lendingPool = LendingPoolInterface(lpAddress);
    
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
        require(_amount >= 500 , "Minimum Deposit amount is $500");
        _;
    }
    
    function _approve(address _spender, uint256 _amount) public returns (bool) {
        dai.approve(_spender, _amount);
        return true;
    }
    
    
    function _deposit(uint256 _amount) public payable minDeposit(_amount) returns(uint) {
        Member storage user = ownerInfo[msg.sender];
        dai.transferFrom(msg.sender, address(this), _amount);
        user.value += _amount;
        dai.approve(lpAddress, _amount);
        lendingPool.deposit(assetAddress, _amount, msg.sender, 0);
        return address(this).balance;
    }
    
    function _claim() public {
        Member memory user = ownerInfo[msg.sender];
        require (user.value > 0, "Cannot claim, Empty Balance!");
        address payable receiver = payable(msg.sender);
        receiver.transfer(user.value);
    }
}
