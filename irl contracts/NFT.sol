// SPDX-License-Identifier: MITX
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MeetNFT is ERC721URIStorage {
    address admin;
    address spender;
    using Counters for Counters.Counter;

    Counters.Counter public _assetCount;

    function totalSupply() external view returns (uint256) {
        return _assetCount.current();
    }

    constructor(address _spender) ERC721("Meet NFT", "MNT") {
        admin = msg.sender;
        spender = _spender;
    }

    function mint(string memory _tokeURI) external onlyAdmin returns (uint256) {
        _assetCount.increment();
        uint256 currentAssetId = _assetCount.current();

        _mint(msg.sender, currentAssetId);
        _setTokenURI(currentAssetId, _tokeURI);
        approve(spender, currentAssetId);

        return currentAssetId;
    }

    function changeApprover(address _spender) public onlyAdmin {
        spender = _spender;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Token: Only admin can perform this operation"
        );
        _;
    }
}
