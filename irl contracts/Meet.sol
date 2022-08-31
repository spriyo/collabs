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

    Counters.Counter public _irlCount;
    Counters.Counter public _giftNFTCount;
    mapping(uint256 => IRL) public _irls;
    mapping(uint256 => GiftNFT) public _giftNfts;
    mapping(address => mapping(uint256 => bool)) private _redeems;

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
        _irlCount.increment();
        uint256 currentIrlId = _irlCount.current();

        IRL storage newIrl = _irls[currentIrlId];
        newIrl.id = currentIrlId;
        newIrl.eventAmount = _eventAmount;
    }

    function joinIrl(uint256 _irlId) public {
        require(
            !_irls[_irlId].participants[msg.sender],
            "Meet: Already joined"
        );
        _irls[_irlId].participants[msg.sender] = true;

        IERC20(tokenAddress).transfer(msg.sender, _irls[_irlId].eventAmount);
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

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Token: Only admin can perform this operation"
        );
        _;
    }
}
