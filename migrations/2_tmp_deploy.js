var OLPReward = artifacts.require("OLPReward");
var OLPContestFactory = artifacts.require("OLPContestFactory");

module.exports = async function (deployer) {
  deployer.deploy(OLPReward)
  .then(function() {
    return deployer.deploy(OLPContestFactory, OLPReward.address);
  })
  .then(async function() {
    rewardInstance = await OLPReward.deployed();
    rewardInstance.setContract(OLPContestFactory.address);
  })
};