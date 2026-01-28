# Simple NFT Marketplace

A lightweight, decentralized marketplace smart contract for trading ERC721 tokens.

## Workflow
1. **List**: Seller calls `listItem()` to put an NFT on sale.
2. **Buy**: Buyer calls `buyItem()` with the required ETH. The NFT is transferred to the buyer, and ETH to the seller.
3. **Cancel**: Seller can `cancelListing()` to remove the item from the market.
4. **Update**: Seller can `updateListing()` to change the price.

## Security
- **Pull over Push**: Funds are sent directly, but the logic uses checks-effects-interactions pattern.
- **Reentrancy Protection**: Uses `ReentrancyGuard` to prevent reentrancy attacks during ETH transfers.

## Prerequisites
- Node.js
- Hardhat

## Setup
1. Install dependencies:
   ```bash
   npm install
