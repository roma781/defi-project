// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyERC20.sol";
import "../src/AMM.sol";

contract AMMTest is Test {
    MyERC20 tokenA;
    MyERC20 tokenB;
    AMM amm;

    address user = address(1);

    function setUp() public {
        tokenA = new MyERC20("A","A");
        tokenB = new MyERC20("B","B");

        amm = new AMM(address(tokenA), address(tokenB));

        tokenA.mint(address(this), 10000 ether);
        tokenB.mint(address(this), 10000 ether);

        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
    }


    function testAddLiquidity() public {
        amm.addLiquidity(100 ether, 100 ether);
        assertGt(amm.reserveA(), 0);
        assertGt(amm.reserveB(), 0);
    }

    function testRemoveLiquidity() public {
        amm.addLiquidity(100 ether, 100 ether);
        amm.removeLiquidity(50 ether);
    }

    function testMultipleLiquidityProviders() public {
        amm.addLiquidity(100 ether, 100 ether);
        amm.addLiquidity(50 ether, 50 ether);
    }


    function testSwapAtoB() public {
        amm.addLiquidity(100 ether, 100 ether);

        tokenA.mint(user, 10 ether);

        vm.startPrank(user);
        tokenA.approve(address(amm), 10 ether);
        amm.swapAforB(10 ether, 0);
        vm.stopPrank();
        vm.expectRevert("slippage");
        amm.swapAforB(50 ether, 100 ether);
    }

    function testSwapBtoA() public {
        amm.addLiquidity(100 ether, 100 ether);
    }

    function testSwapImpactChangesReserves() public {
        amm.addLiquidity(100 ether, 100 ether);
        amm.swapAforB(10 ether, 0);
        assertGt(amm.reserveA(), 100 ether);
    }


    function testSmallSwap() public {
        amm.addLiquidity(100 ether, 100 ether);
        amm.swapAforB(1 wei, 0);
    }

    function testLargeSwap() public {
        amm.addLiquidity(1000 ether, 1000 ether);
        amm.swapAforB(300 ether, 0);
    }



    function testFuzzSwap(uint256 amount) public {
        amm.addLiquidity(1000 ether, 1000 ether);

        amount = bound(amount, 1 ether, 50 ether);

        tokenA.mint(user, amount);

        vm.startPrank(user);
        tokenA.approve(address(amm), amount);
        amm.swapAforB(amount, 0);
        vm.stopPrank();
    }


    function invariant_reservesNonNegative() public view {
        assertGe(amm.reserveA(), 0);
        assertGe(amm.reserveB(), 0);
    }
}