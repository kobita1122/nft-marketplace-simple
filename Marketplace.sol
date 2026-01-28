// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    // NFT Contract Address -> Token ID -> Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    // Events
    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    // Modifiers
    modifier isNotListed(address nftAddress, uint256 tokenId) {
        require(listings[nftAddress][tokenId].price == 0, "Already listed");
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        require(listings[nftAddress][tokenId].price > 0, "Not listed");
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        require(owner == spender, "Not owner");
        _;
    }

    /////////////////////
    // Main Functions //
    /////////////////////

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external isNotListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
        require(price > 0, "Price must be > 0");
        
        // Check if marketplace is approved
        IERC721 nft = IERC721(nftAddress);
        require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "Not approved for marketplace");

        listings[nftAddress][tokenId] = Listing(msg.sender, price);

        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function buyItem(address nftAddress, uint256 tokenId)
        external
        payable
        nonReentrant
        isListed(nftAddress, tokenId)
    {
        Listing memory listedItem = listings[nftAddress][tokenId];
        require(msg.value == listedItem.price, "Incorrect price");

        // Delete listing before transfer (Checks-Effects-Interactions)
        delete listings[nftAddress][tokenId];

        // Transfer payment to seller
        (bool success, ) = payable(listedItem.seller).call{value: msg.value}("");
        require(success, "Transfer failed");

        // Transfer NFT to buyer
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);

        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        delete listings[nftAddress][tokenId];
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    ) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
        require(newPrice > 0, "Price must be > 0");
        listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }
}
