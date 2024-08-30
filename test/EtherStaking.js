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
    await etherStaking.deployed();
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

});