// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeetToken is ERC20, ERC20Burnable, Ownable {
    address public admin;

    constructor(uint256 initialSupply) ERC20("Meet Token", "MTT") {
        _mint(msg.sender, initialSupply);
        admin = msg.sender;
    }
}
