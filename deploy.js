const hre = require("hardhat");

async function main() {
  const [deployer, user1] = await hre.ethers.getSigners();

  // 1. Deploy Marketplace
  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();
  await marketplace.waitForDeployment();
  console.log(`Marketplace deployed to: ${marketplace.target}`);

  // 2. Deploy Mock NFT
  const MockNFT = await hre.ethers.getContractFactory("MockNFT");
  const nft = await MockNFT.deploy();
  await nft.waitForDeployment();
  console.log(`Mock NFT deployed to: ${nft.target}`);

  // 3. Demo: Mint and List an Item
  // Mint Token ID 0
  await nft.mint(); 
  
  // Approve Marketplace
  await nft.approve(marketplace.target, 0);

  // List Item for 1 ETH
  await marketplace.listItem(nft.target, 0, hre.ethers.parseEther("1.0"));
  console.log("Listed NFT #0 for 1 ETH");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
