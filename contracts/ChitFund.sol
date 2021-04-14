// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {LendingPoolInterface} from "./LendingPool.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
 
interface DateTimeInterface {
    function getDay(uint timestamp) external pure returns (uint8);
}

contract ChitFund {
    
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
    
    modifier minDeposit() {
        require(msg.value >= 1 ether, "Minimum Deposit amount is 1 ETH");
        _;
    }
    
    
    
    function _deposit() public payable minDeposit() returns(uint)  {
        Member storage user = ownerInfo[msg.sender];
        user.value += msg.value;
        
        lendingPool.deposit(assetAddress, msg.value, msg.sender, 0);
        return address(this).balance;
    }
    
    function _claim() public {
        Member memory user = ownerInfo[msg.sender];
        require (user.value > 0, "Cannot claim, Empty Balance!");
        address payable receiver = payable(msg.sender);
        receiver.transfer(user.value);
    }
}
