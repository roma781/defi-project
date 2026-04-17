pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyERC20.sol";

contract T is Test {
    MyERC20 t;

    function setUp() public {
        t = new MyERC20("T","T");
        t.mint(address(this),1000);
    }

    function testTransfer() public {
        t.transfer(address(1),100);
        assertEq(t.balanceOf(address(1)),100);
    }
}
