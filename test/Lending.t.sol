// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyERC20.sol";
import "../src/LendingPool.sol";

contract LendingTest is Test {
    MyERC20 token;
    LendingPool pool;

    address user = address(1);
    address liquidator = address(2);

    function setUp() public {
        token = new MyERC20("T","T");
        pool = new LendingPool(address(token));

        token.mint(user, 1000 ether);
        token.mint(liquidator, 1000 ether);

        vm.startPrank(user);
        token.approve(address(pool), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(liquidator);
        token.approve(address(pool), type(uint256).max);
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.prank(user);
        pool.deposit(100 ether);

        assertEq(pool.collateral(user), 100 ether);
    }

    function testBorrow() public {
        vm.startPrank(user);
        pool.deposit(100 ether);
        pool.borrow(50 ether);
        vm.stopPrank();

        assertEq(pool.debt(user), 50 ether);
    }

    function testRepay() public {
        vm.startPrank(user);
        pool.deposit(100 ether);
        pool.borrow(50 ether);
        pool.repay(50 ether);
        vm.stopPrank();

        assertEq(pool.debt(user), 0);
    }

    function testBorrowLimitRevert() public {
        vm.startPrank(user);
        pool.deposit(100 ether);

        vm.expectRevert();
        pool.borrow(1000 ether);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(user);
        pool.deposit(100 ether);
        pool.withdraw(40 ether);
        vm.stopPrank();
    }

    function test_RevertWhen_UnsafeWithdraw() public {
        vm.startPrank(user);
        pool.deposit(100 ether);
        pool.borrow(50 ether);

        vm.expectRevert();
        pool.withdraw(100 ether);

        vm.stopPrank();
    }

    // ---------- TIME / INTEREST ----------

    function testInterestTimeWarp() public {
        vm.startPrank(user);
        pool.deposit(100 ether);
        pool.borrow(50 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);

        assertTrue(pool.debt(user) >= 50 ether);
    }

    // ---------- LIQUIDATION SIMULATION ----------

    // function testLiquidationFlow() public {
    //     vm.startPrank(user);
    //     pool.deposit(100 ether);
    //     pool.borrow(70 ether);
    //     vm.stopPrank();

    //     vm.startPrank(liquidator);
    //     pool.repay(20 ether);
    //     vm.stopPrank();
    // }
}