pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyERC20.sol";
import "../src/AMM.sol";

contract S is Script {
    function run() external {
        vm.startBroadcast();
        MyERC20 a = new MyERC20("A","A");
        MyERC20 b = new MyERC20("B","B");
        new AMM(address(a),address(b));
        vm.stopBroadcast();
    }
}
