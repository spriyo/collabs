// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, ERC20Burnable, Ownable {
    mapping(address => bool) public admins;

    constructor(uint256 initialSupply) ERC20("IRL Token", "IRLT") {
        _mint(msg.sender, initialSupply);
        admins[msg.sender] = true;
    }

    function mintTokens(address _to, uint256 _supply) public onlyAdmins {
        _mint(_to, _supply);
    }

    function addAdmin(address _newAdmin) public onlyAdmins {
        admins[_newAdmin] = true;
    }

    modifier onlyAdmins() {
        require(admins[msg.sender], "Token: Only admins can mint tokens");
        _;
    }
}
