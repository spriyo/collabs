// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract IRLNFT is ERC1155, ERC1155Burnable, ERC1155Supply {
    mapping(address => bool) public admins;

    constructor() ERC1155("") {
        admins[msg.sender] = true;
    }

    function setURI(string memory newuri) public onlyAdmins {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyAdmins {
        require(id <= 5 && id > 0, "NFT: Invalid Id.");
        _mint(account, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyAdmins {
        for (uint8 i = 0; i < ids.length; i++) {
            require(ids[i] <= 5 && ids[i] > 0, "NFT: Invalid Id.");
        }

        _mintBatch(to, ids, amounts, "");
    }

    function addAdmin(address _newAdmin) public onlyAdmins {
        admins[_newAdmin] = true;
    }

    modifier onlyAdmins() {
        require(admins[msg.sender], "NFT: Only admins can mint tokens");
        _;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
