// SPDX-License-Identifier: MITX
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Meet {
    address admin;
    address tokenAddress;
    address NFTAddress;
    using Counters for Counters.Counter;

    struct IRL {
        uint256 id;
        uint256 eventAmount;
        mapping(address => bool) participants;
    }

    struct GiftNFT {
        uint256 redeemAmount;
        uint256 tokenId;
    }

    Counters.Counter public irlCount;
    Counters.Counter public _giftNFTCount;
    mapping(uint256 => IRL) public irls;
    mapping(uint256 => GiftNFT) public _giftNfts;
    mapping(address => mapping(uint256 => bool)) private _redeems;
    mapping(uint256 => mapping(address => mapping(address => bool)))
        public interactions;

    constructor(address _tokenAddress, address _nftAddress) {
        admin = msg.sender;
        tokenAddress = _tokenAddress;
        NFTAddress = _nftAddress;
    }

    function createGiftNft(uint256 _tokenId, uint256 _reedemAmount)
        public
        onlyAdmin
    {
        _giftNFTCount.increment();
        _giftNfts[_giftNFTCount.current()] = GiftNFT({
            tokenId: _tokenId,
            redeemAmount: _reedemAmount
        });
    }

    function createIrl(uint256 _eventAmount) public onlyAdmin {
        irlCount.increment();
        uint256 currentIrlId = irlCount.current();

        IRL storage newIrl = irls[currentIrlId];
        newIrl.id = currentIrlId;
        newIrl.eventAmount = _eventAmount;
    }

    function joinIrl(uint256 _irlId) public {
        require(!irls[_irlId].participants[msg.sender], "Meet: Already joined");
        irls[_irlId].participants[msg.sender] = true;

        IERC20(tokenAddress).transfer(msg.sender, irls[_irlId].eventAmount);
    }

    function reedemNFT(uint256 _giftId) public {
        require(!_redeems[msg.sender][_giftId], "Meet: NFT Already redeemed!");
        _redeems[msg.sender][_giftId] = true;
        IERC721(NFTAddress).transferFrom(
            address(this),
            msg.sender,
            _giftNfts[_giftId].tokenId
        );
    }

    function interact(uint256 _irlId, address _userAddress)
        public
        returns (bool)
    {
        if (
            interactions[_irlId][msg.sender][_userAddress] ||
            interactions[_irlId][_userAddress][msg.sender]
        ) return false;
        interactions[_irlId][msg.sender][_userAddress] = true;
        interactions[_irlId][_userAddress][msg.sender] = true;
        return true;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Token: Only admin can perform this operation"
        );
        _;
    }
}
