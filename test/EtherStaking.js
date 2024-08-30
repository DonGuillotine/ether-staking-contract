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

});