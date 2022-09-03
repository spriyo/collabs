// SPDX-License-Identifier: MITX
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Meet {
    mapping(address => bool) public admins;
    address tokenAddress;
    address NFTAddress;
    using Counters for Counters.Counter;

    struct IRL {
        uint256 id;
        string image;
        string name;
        mapping(address => bool) participants;
    }

    struct GiftNFT {
        uint256 redeemAmount;
        uint256 tokenId;
    }

    struct Activity {
        uint256 id;
        uint256 irlId;
        string name;
        uint256 award;
    }

    Counters.Counter public irlCount;
    Counters.Counter public _giftNFTCount;
    Counters.Counter public _activityCount;
    mapping(uint256 => IRL) public irls;
    mapping(uint256 => GiftNFT) public _giftNfts;
    mapping(uint256 => mapping(uint256 => Activity)) public activities;
    mapping(address => mapping(uint256 => bool)) private _redeems;
    // mapping(uint256 => mapping(address => mapping(address => bool))) public interactions;
    mapping(uint256 => mapping(uint256 => mapping(address => bool)))
        public activityInteractions;

    constructor() {
        // address _tokenAddress, address _nftAddress
        admins[msg.sender] = true;
        tokenAddress = address(0xa13E0E8156972817e6E89934b41A2bE21F8Ab367);
        NFTAddress = address(0x09d4c32e553B8d209CDDdD9b2773613574AB927d);
    }

    function createGiftNft(uint256 _tokenId, uint256 _reedemAmount)
        public
        onlyAdmins
    {
        _giftNFTCount.increment();
        _giftNfts[_giftNFTCount.current()] = GiftNFT({
            tokenId: _tokenId,
            redeemAmount: _reedemAmount
        });
    }

    function createIrl(string memory _image, string memory _name)
        public
        onlyAdmins
        returns (uint256)
    {
        irlCount.increment();
        uint256 currentIrlId = irlCount.current();

        IRL storage newIrl = irls[currentIrlId];
        newIrl.id = currentIrlId;
        newIrl.name = _name;
        newIrl.image = _image;

        return currentIrlId;
    }

    function reedemNFT(uint256 _giftId) public {
        require(!_redeems[msg.sender][_giftId], "Meet: NFT Already redeemed!");
        _redeems[msg.sender][_giftId] = true;
        IERC20(tokenAddress).transfer(
            address(this),
            _giftNfts[_giftId].redeemAmount
        );
        IERC721(NFTAddress).transferFrom(
            address(this),
            msg.sender,
            _giftNfts[_giftId].tokenId
        );
    }

    function createActivity(
        uint256 _irlId,
        string memory _activityName,
        uint256 _award
    ) public onlyAdmins {
        _activityCount.increment();
        uint256 _currentActivityCount = _activityCount.current();
        activities[_irlId][_currentActivityCount] = Activity({
            id: _activityCount.current(),
            irlId: _irlId,
            name: _activityName,
            award: _award
        });
    }

    function interact(uint256 _irlId, uint256 _activityId) public {
        require(_irlId <= irlCount._value, "Meet: Invalid IRL id.");
        require(
            !activityInteractions[_irlId][_activityId][msg.sender],
            "Meet: Already interacted"
        );
        activityInteractions[_irlId][_activityId][msg.sender] = true;

        bool sent = IERC20(tokenAddress).transfer(
            msg.sender,
            activities[_irlId][_activityId].award
        );
        require(sent, "Meet: token transfer failed");
    }

    modifier onlyAdmins() {
        require(admins[msg.sender], "Token: Only admins can mint tokens");
        _;
    }
}
