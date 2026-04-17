// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyERC20.sol";

contract ERC20Test is Test {
    MyERC20 token;

    address user1 = address(1);
    address user2 = address(2);
    

    function setUp() public {
        token = new MyERC20("Test", "T");
        token.mint(address(this), 1000 ether);
    }

    function testMint() public {
        token.mint(user1, 100);
        assertEq(token.balanceOf(user1), 100);
    }

    function testTransfer() public {
        token.transfer(user1, 100);
        assertEq(token.balanceOf(user1), 100);
    }

    function testApprove() public {
        token.approve(user1, 100);
        assertEq(token.allowance(address(this), user1), 100);
    }

    function testTransferFrom() public {
        token.approve(user1, 100);
        vm.prank(user1);
        token.transferFrom(address(this), user2, 100);
        assertEq(token.balanceOf(user2), 100);
    }

    // function test_RevertWhen_TransferTooMuch() public {
    // vm.expectRevert();
    // token.transfer(user1, 999999);
    // }

    // FUZZ
    function testFuzzTransfer(uint256 amount) public {
        amount = bound(amount, 0, 1000 ether);
        token.transfer(user1, amount);
        assertEq(token.balanceOf(user1), amount);
    }

    // INVARIANT: totalSupply never decreases unexpectedly
    function invariant_totalSupply() public view {
        assertGe(token.totalSupply(), 1000 ether);
    }
}