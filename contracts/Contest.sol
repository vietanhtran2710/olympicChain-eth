// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

// Reward for the best only.
contract Contest is Ownable {
    enum Stages {
        REGISTER,
        ON_GOING,
        FINISHED
    }
    Stages stage;

    // Update this to something like:
    // struct UpdatedReward {
    //     uint256[] tokenIds;
    //     uint256[] amounts;
    // }

    struct Reward {
        uint256[] collectiblesTokenId;
        uint256 vnhToken;
    }
    address[] sponsors;
    mapping(address => Reward) sponsorReward;

    address[] contestants;
    mapping(address => uint256) contestantsResult;

    uint256 totalVnhReward;
    uint256[] totalNftReward;

    constructor() {
        stage = Stages.REGISTER;
    }

    function getStudentResults() public view returns (uint256[] memory) {
        uint256[] memory grades = new uint256[](contestants.length);
        for (uint256 i = 0; i < contestants.length; i++) {
            grades[i] = contestantsResult[contestants[i]];
        }
        return grades;
    }

    function getStudents() public view returns (address[] memory) {
        return contestants;
    }

    function getStage() public view returns (uint256) {
        if (stage == Stages.REGISTER) return 0;
        if (stage == Stages.ON_GOING) return 1;
        return 2;
    }

    function finishRegister() public onlyOwner {
        require(stage == Stages.REGISTER, "Contest is not in register stage");
        stage = Stages.ON_GOING;
    }

    function endContest() public onlyOwner {
        require(stage == Stages.ON_GOING, "Contest is not started");
        stage = Stages.FINISHED;
    }

    function getTopWinner() public view returns (address) {
        address winner;
        uint256 max = 0;
        uint256 numberOfContestants = contestants.length;
        for (uint256 i = 0; i < numberOfContestants; i++) {
            if (contestantsResult[contestants[i]] > max) {
                max = contestantsResult[contestants[i]];
                winner = contestants[i];
            }
        }
        return winner;
    }

    function getSponsors() public view returns (address[] memory) {
        return sponsors;
    }

    function getVNHRewards(address sponsor) public view returns (uint256) {
        return sponsorReward[sponsor].vnhToken;
    }

    function getNFTRewards(address sponsor)
        public
        view
        returns (uint256[] memory)
    {
        return sponsorReward[sponsor].collectiblesTokenId;
    }

    function register(address student) public {
        require(stage == Stages.REGISTER, "Contest is not in register stage");
        // Already 0 as default.
        //contestantsResult[student] = 0;
        contestants.push(student);
    }

    function registerBatch(address[] memory students) public {
        require(stage == Stages.REGISTER, "Contest is not in register stage");
        for (uint256 i = 0; i < students.length; ++i) {
            // Already 0 in default.
            //contestantsResult[students[i]] = 0;
            contestants.push(students[i]);
        }
    }

    function updateGrade(address student, uint256 grade) public onlyOwner {
        require(stage == Stages.ON_GOING, "Contest is not started");
        contestantsResult[student] = grade;
    }

    function updateBatchGrade(
        address[] memory students,
        uint256[] memory grades
    ) public onlyOwner {
        require(stage == Stages.ON_GOING, "Contest is not started");
        for (uint256 i = 0; i < students.length; ++i) {
            contestantsResult[students[i]] = grades[i];
        }
    }

    function registerReward(
        address _sponsor,
        uint256 _totalVnh,
        uint256[] memory _nfts
    ) public {
        sponsors.push(_sponsor);
        sponsorReward[_sponsor] = Reward({
            vnhToken: _totalVnh,
            collectiblesTokenId: _nfts
        });
        totalVnhReward += _totalVnh;
        for (uint256 i = 0; i < _nfts.length; ++i) {
            totalNftReward.push(_nfts[i]);
        }
    }

    function getTotalVnhReward() public view returns (uint256) {
        return totalVnhReward;
    }

    function getTotalNftReward() public view returns (uint256[] memory) {
        return totalNftReward;
    }
}
