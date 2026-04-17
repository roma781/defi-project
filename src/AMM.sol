// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "./MyERC20.sol";
import "./LPToken.sol";

contract AMM {
    MyERC20 public tokenA;
    MyERC20 public tokenB;
    LPToken public lpToken;

    uint256 public reserveA;
    uint256 public reserveB;

    constructor(address a, address b) {
        tokenA = MyERC20(a);
        tokenB = MyERC20(b);
        lpToken = new LPToken();
    }

    function addLiquidity(uint256 a, uint256 b) external {
        tokenA.transferFrom(msg.sender, address(this), a);
        tokenB.transferFrom(msg.sender, address(this), b);
        lpToken.mint(msg.sender, a);
        reserveA += a;
        reserveB += b;
    }

    function getAmountOut(uint256 amountIn, uint256 rIn, uint256 rOut) public pure returns (uint256) {
        uint256 amountInWithFee = amountIn * 997;
        return (amountInWithFee * rOut) / (rIn * 1000 + amountInWithFee);
    }

    function swapAforB(uint256 amountIn, uint256 minOut) external returns (uint256 out) {
    tokenA.transferFrom(msg.sender, address(this), amountIn);

    uint256 amountInWithFee = (amountIn * 997) / 1000;

    out = (amountInWithFee * reserveB) / (reserveA + amountInWithFee);

    require(out >= minOut, "slippage");

    reserveA += amountIn;
    reserveB -= out;

    tokenB.transfer(msg.sender, out);
    }

    function removeLiquidity(uint256 liquidity) external {
    uint256 amountA = (liquidity * reserveA) / lpToken.totalSupply();
    uint256 amountB = (liquidity * reserveB) / lpToken.totalSupply();

    lpToken.burn(msg.sender, liquidity);

    reserveA -= amountA;
    reserveB -= amountB;

    tokenA.transfer(msg.sender, amountA);
    tokenB.transfer(msg.sender, amountB);
    }
}
