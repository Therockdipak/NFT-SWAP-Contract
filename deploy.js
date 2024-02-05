// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers} = require("hardhat");

async function main() {
  const name1 = "AToken"; 
  const tokenA = await ethers.deployContract(name1);
  await tokenA.waitForDeployment();
  console.log(`AToken deployed at ${tokenA.target}`);

   const name2 = "BToken";
   const tokenB = await ethers.deployContract(name2);
   await tokenB.waitForDeployment();
   console.log(`BToken deployed at ${tokenB.target}`);

   const name3 = "TokenSwap";
   const TokenSwap = await ethers.deployContract(name3,[tokenA.target,tokenB.target]);
   await TokenSwap.waitForDeployment();
   console.log(`TokenSwap deployed at ${TokenSwap.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
