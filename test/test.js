let olpReward = artifacts.require("./OLPReward.sol");
let contest = artifacts.require("./OLPContestFactory.sol");

let rewardInstance, contestInstance;

let contractAddress, contestId;

contract('Contracts', function (accounts) {
    it("Contracts deployment", function() {
        return olpReward.deployed().then(function(instance) {
            rewardInstance = instance;
            assert(rewardInstance != undefined, "OLPProcessReward should be defined/deployed");
        })
        .then(function() {
            return contest.deployed().then(function(instance) {
                contestInstance = instance;
                contractAddress = contestInstance.address;
                assert(contestInstance != undefined, "OLPContestFactory should be deployed");
            })
        });
    });

    it("Access control test", function() {
        return rewardInstance.isAdmin(accounts[0], {from: accounts[0]})
        .then(async function(result) {
            assert.equal(1, result, "Account 0 should be admin");
            await rewardInstance.addStudent(accounts[1], {from: accounts[0]})
            return rewardInstance.isStudent(accounts[1], {from: accounts[0]})
        })
        .then(async function(result) {
            assert.equal(1, result, "Account 1 should be a student");
            await rewardInstance.addTeacher(accounts[2], {from: accounts[0]})
            return rewardInstance.isTeacher(accounts[2], {from: accounts[0]})
        })
        .then(async function(result) {
            assert.equal(1, result, "Account 2 should be a teacher");
            await rewardInstance.addParent(accounts[3], {from: accounts[0]})
            return rewardInstance.isParent(accounts[3], {from: accounts[0]})
        })
        .then(async function(result) {
            assert.equal(1, result, "Account 3 should be a parent");
            await rewardInstance.addSponsor(accounts[4], {from: accounts[0]})
            
            return rewardInstance.isSponsor(accounts[4], {from: accounts[0]})
        })
        .then(function(result) {
            assert.equal(1, result, "Account 4 should be a sponsor");
        })
    })

    it("Sponsor approval", function() {
        return rewardInstance.approveForContract({from: accounts[4]})
        .then(function (){
            return rewardInstance.isApprovedForAll(accounts[4], contractAddress, {from: accounts[0]})
        })
        .then(function (result) {
            assert.equal(true, result, "Sponsor at account 4 should approved");
        })
    })

    it("KNG Token mint test", function() {
        return rewardInstance.kngTokenProcessReward(accounts[1], {from: accounts[0]})
        .then(function(result) {
            return rewardInstance.balanceOf(accounts[1], 0, {from: accounts[0]})
            .then(function(result) {
                assert.equal(10, result.toNumber(), "KNG Token should be minted");
            });
        })
    })

    it("VNH Token mint test", function() {
        return rewardInstance.mintVNH(accounts[4], 100, [], {from: accounts[0]})
        .then(function(result) {
            return rewardInstance.balanceOf(accounts[4], 1, {from: accounts[0]}).
            then(function(result) {
                assert.equal(100, result.toNumber(), "VNH Token should be minted");
            });
        })
    })

    it("Process Reward negative test case", function() {
        return rewardInstance.createStudyProgressReward(accounts[1], 110, 10, {from: accounts[4]})
        .then(function(result) {
            throw("Condition not implemented in Smart Contract");
        }).catch(function (e) {
            if(e === "Condition not implemented in Smart Contract") {
                assert(false);
            } else {
                assert(true);
            }
        })
    })

    it("Process Reward positive test case", async function() {
        return rewardInstance.createStudyProgressReward(accounts[1], 40, 20, {from: accounts[4]})
        .then(function(result) {
            return rewardInstance.kngTokenProcessReward(accounts[1], {from: accounts[0]})
            .then(function(result) {
                return rewardInstance.balanceOf(accounts[4], 1, {from: accounts[0]})
                .then(function(result) {
                    assert.equal(60, result.toNumber(), "VNH reward should have transferred");
                    return rewardInstance.balanceOf(accounts[1], 1, {from: accounts[1]})
                    .then(function(result) {
                        assert.equal(40, result.toNumber(), "VNH reward should have received");
                    })
                });
            })
        })
    })

    it("Contest Reward test", async function() {
        tx = await contestInstance.createNewContest({from: accounts[0]});
        contestId = tx.logs[1]['args']['0'];
        return contestInstance.getNumberOfContests({from: accounts[0]})
        .then(async function(result) {
            assert.equal(1, result.toNumber(), "Contest should be created");
            await contestInstance.registerReward(contestId, 60, [], {from: accounts[4]});
            return rewardInstance.balanceOf(accounts[4], 1, {from: accounts[4]})
        })
        .then(async function(result) {
            assert.equal(0, result.toNumber(), "Rewards should be transferred");
            await rewardInstance.addStudent(accounts[5], {from: accounts[0]})
            await contestInstance.registerStudent(accounts[5], contestId, {from: accounts[0]})
            await contestInstance.registerStudent(accounts[1], contestId, {from: accounts[0]})
            await contestInstance.startContest(contestId, {from: accounts[0]})
            await contestInstance.updateGrade(contestId, accounts[5], 9, {from: accounts[0]})
            await contestInstance.updateGrade(contestId, accounts[1], 10, {from: accounts[0]})
            await contestInstance.endContest(contestId, {from: accounts[0]})
            return rewardInstance.balanceOf(accounts[1], 1, {from: accounts[0]})
        })
        .then(function(result) {
            assert.equal(100, result.toNumber(), "Rewards should be transferred to winner");
        })
    })


    
});