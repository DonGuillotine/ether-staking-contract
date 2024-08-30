const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EtherStaking", function () {
  let EtherStaking;
  let etherStaking;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    EtherStaking = await ethers.getContractFactory("EtherStaking");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    etherStaking = await EtherStaking.deploy();
    await etherStaking.waitForDeployment();

    await owner.sendTransaction({
        to: etherStaking.getAddress(),
        value: ethers.parseEther("10"),
    });
  });

  describe("Staking", function () {
    it("Should allow successful staking", async function () {
      const stakeAmount = ethers.parseEther("1");
      await expect(etherStaking.connect(addr1).stakeEther({ value: stakeAmount }))
        .to.emit(etherStaking, "Staked")
        .withArgs(addr1.address, stakeAmount);

      const stake = await etherStaking.getStakeInfo(addr1.address);
      expect(stake.amount).to.equal(stakeAmount);
    });

    it("Should not allow staking with zero Ether", async function () {
      await expect(etherStaking.connect(addr1).stakeEther({ value: 0 }))
        .to.be.revertedWith("Must stake some Ether");
    });

    it("Should not allow staking while already having an active stake", async function () {
      const stakeAmount = ethers.parseEther("1");
      await etherStaking.connect(addr1).stakeEther({ value: stakeAmount });

      await expect(etherStaking.connect(addr1).stakeEther({ value: stakeAmount }))
        .to.be.revertedWith("Already staking");
    });
  });

  describe("Reward Calculation", function () {
    it("Should calculate rewards correctly for different durations", async function () {
        const stakeAmount = ethers.parseEther("1");
        await etherStaking.connect(addr1).stakeEther({ value: stakeAmount });

        await ethers.provider.send("evm_increaseTime", [10 * 24 * 60 * 60]);
        await ethers.provider.send("evm_mine");

        const reward = await etherStaking.calculateReward(addr1.address);
        const expectedReward = (stakeAmount * 10n) / 1000n;
        expect(reward).to.equal(expectedReward);
    });

    it("Should return zero reward before minimum staking period", async function () {
      const stakeAmount = ethers.parseEther("1");
      await etherStaking.connect(addr1).stakeEther({ value: stakeAmount });

      await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]);
      await ethers.provider.send("evm_mine");

      const reward = await etherStaking.calculateReward(addr1.address);
      expect(reward).to.equal(0);
    });
  });

  describe("Withdrawal", function () {
    it("Should allow successful withdrawal after minimum staking period", async function () {
        const stakeAmount = ethers.parseEther("1");
        await etherStaking.connect(addr1).stakeEther({ value: stakeAmount });

        await ethers.provider.send("evm_increaseTime", [10 * 24 * 60 * 60]);
        await ethers.provider.send("evm_mine");

        const balanceBefore = await ethers.provider.getBalance(addr1.address); 
        const tx = await etherStaking.connect(addr1).withdraw();
        const receipt = await tx.wait();
        const gasCost = receipt.gasUsed * tx.gasPrice; 

        const balanceAfter = await ethers.provider.getBalance(addr1.address);
        const expectedReward = (stakeAmount * 10n) / 1000n;
        const expectedBalance = balanceBefore + stakeAmount + expectedReward - gasCost;

        expect(balanceAfter).to.equal(expectedBalance);
    });

    it("Should not allow withdrawal before minimum staking period", async function () {
      const stakeAmount = ethers.parseEther("1");
      await etherStaking.connect(addr1).stakeEther({ value: stakeAmount });

      await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]);
      await ethers.provider.send("evm_mine");

      await expect(etherStaking.connect(addr1).withdraw())
        .to.be.revertedWith("Minimum staking period not met");
    });

    it("Should not allow withdrawal with no stake", async function () {
      await expect(etherStaking.connect(addr1).withdraw())
        .to.be.revertedWith("No stake to withdraw");
    });
  });

  describe("Security", function () {
    it("Should protect against reentrancy", async function () {
      const AttackContract = await ethers.getContractFactory("AttackContract");
      const attackContract = await AttackContract.deploy(etherStaking.address);
      await attackContract.waitForDeployment();

      await expect(attackContract.attack({ value: ethers.parseEther("1") }))
        .to.be.revertedWith("ReentrancyGuard: reentrant call");
    });

    it("Should restrict access to owner functions", async function () {
      await expect(etherStaking.connect(addr1).emergencyWithdraw())
        .to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

});