const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const EtherStaking = await hre.ethers.getContractFactory("EtherStaking");
  const etherStaking = await EtherStaking.deploy();

  await etherStaking.waitForDeployment();

  const etherStakingAddress = await etherStaking.getAddress();

  console.log("EtherStaking deployed to:", await etherStaking.getAddress());

  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Waiting for block confirmations...");
    await etherStaking.deploymentTransaction().wait(5);
    
    console.log("Verifying contract...");
    await hre.run("verify:verify", {
      address: etherStakingAddress,
      constructorArguments: [],
    });
  }

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });