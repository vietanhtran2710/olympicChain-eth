// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

// Reward for the best only.
contract Contest is Ownable {
    struct Reward {
        uint256[] collectiblesTokenId;
        uint256 vnhToken;
    }

    struct Result {
        uint256 grade;
        uint256 time;
    }
    address[] sponsors;
    mapping(address => Reward) sponsorReward;

    address[] contestants;
    mapping(address => Result) contestantsResult;

    uint256 totalVnhReward;
    uint256[] totalNftReward;

    bytes[] answers;

    constructor(bytes[] memory _answers) {
        answers = _answers;
    }

    function getStudentResults() public view returns (Result[] memory) {
        Result[] memory grades = new Result[](contestants.length);
        for (uint256 i = 0; i < contestants.length; i++) {
            grades[i] = contestantsResult[contestants[i]];
        }
        return grades;
    }

    function getStudents() public view returns (address[] memory) {
        return contestants;
    }

    function getTopWinner() public view returns (address) {
        address winner;
        uint256 max = 0;
        uint256 time = 0;
        uint256 numberOfContestants = contestants.length;
        for (uint256 i = 0; i < numberOfContestants; i++) {
            if (contestantsResult[contestants[i]].grade > max) {
                max = contestantsResult[contestants[i]].grade;
                winner = contestants[i];
                time = contestantsResult[contestants[i]].time;
            }
            else if (contestantsResult[contestants[i]].grade == max) {
                if (contestantsResult[contestants[i]].time < time) {
                    winner = contestants[i];
                    time = contestantsResult[contestants[i]].time;
                }
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
        contestants.push(student);
    }

    function registerBatch(address[] memory students) public {
        for (uint256 i = 0; i < students.length; ++i) {
            contestants.push(students[i]);
        }
    }

    function gradeSubmission(address student, bytes[] calldata submission, uint time) public onlyOwner {
        uint grade = 0;
        for (uint256 i = 0; i < answers.length; i++) {
            bytes memory a = answers[i]; bytes memory b = submission[i];
            if (keccak256(a) == keccak256(b)) grade++;
        }
        contestantsResult[student].grade = grade;
        contestantsResult[student].time = time;
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
