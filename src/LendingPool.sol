// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "./MyERC20.sol";

contract LendingPool {
    MyERC20 public token;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;

    constructor(address t) {
        token = MyERC20(t);
    }

    function deposit(uint256 a) external {
        token.transferFrom(msg.sender, address(this), a);
        collateral[msg.sender] += a;
    }

    function borrow(uint256 a) external {
        require(debt[msg.sender] + a <= (collateral[msg.sender] * 75) / 100);
        debt[msg.sender] += a;
        token.transfer(msg.sender, a);
    }

    function repay(uint256 a) external {
        token.transferFrom(msg.sender, address(this), a);
        debt[msg.sender] -= a;
    }

    function withdraw(uint256 amount) external {
        require(collateral[msg.sender] >= amount, "not enough collateral");
        require(collateral[msg.sender] - amount >= debt[msg.sender], "unsafe");

        collateral[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }
    
    function liquidate(address user, uint256 amount) external {
        require(debt[user] > 0, "no debt");

        uint256 repayAmount = amount;

        if (repayAmount > debt[user]) {
            repayAmount = debt[user];
        }

        debt[user] -= repayAmount;

        uint256 collateralSeized = repayAmount;

        require(collateral[user] >= collateralSeized, "not enough collateral");

        collateral[user] -= collateralSeized;

        token.transfer(msg.sender, collateralSeized);
    }
}
