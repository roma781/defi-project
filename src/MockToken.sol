// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20.sol";

contract MockToken is ERC20 {
    address public owner;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol, 18) {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        _burn(from, amount);
    }
}
