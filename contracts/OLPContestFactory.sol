// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./OLPReward.sol";
import "./Contest.sol";

pragma solidity ^0.8.0;

contract OLPContestFactory is Ownable {
    uint256 public constant KNG_ID = 0;
    uint256 public constant VNH_ID = 1;

    event CreatedContest(address id);

    mapping(address => Contest) contests;
    OLPReward olpContract;
    address olpAddress;
    uint256 totalContest = 0;

    constructor(address olpContractAddress) {
        olpContract = OLPReward(olpContractAddress);
        olpAddress = olpContractAddress;
    }

    function createNewContest(bytes[] memory answers) public onlyOwner returns (address) {
        bytes32 tmpData = keccak256(
            abi.encodePacked(msg.sender, block.timestamp)
        );
        address tokenId = address(bytes20(tmpData));
        contests[tokenId] = new Contest(answers);
        totalContest++;
        emit CreatedContest(tokenId);
        return tokenId;
    }

    function endContest(address contestId) public onlyOwner {
        address winner = contests[contestId].getTopWinner();

        // Send reward (from contract's balance) the to winner.
        uint256 len = contests[contestId].getTotalNftReward().length;

        uint256[] memory ids = new uint256[](len + 1);
        uint256[] memory amounts = new uint256[](len + 1);

        for (uint256 i = 0; i < len; ++i) {
            ids[i] = contests[contestId].getTotalNftReward()[i];
            amounts[i] = 1;
        }

        ids[len] = VNH_ID;
        amounts[len] = contests[contestId].getTotalVnhReward();
        olpContract.withdrawBatchFromContract(winner, ids, amounts, "");
    }

    function gradeSubmission(
        address contestId,
        address student,
        bytes[] memory submission,
        uint256 time
    ) public onlyOwner {
        contests[contestId].gradeSubmission(student, submission, time);
    }

    // Sponsors call this function.
    function registerReward(
        address contestId,
        uint256 vnhAmount,
        uint256[] memory nfts
    ) public {
        // onlySponsor.
        require(
            olpContract.isSponsor(msg.sender),
            "OLPContestFactory: only role sponsor"
        );

        // Send sponsor's registed reward token to contract's balance.
        uint256 len = nfts.length;

        uint256[] memory ids = new uint256[](len + 1);
        uint256[] memory amounts = new uint256[](len + 1);

        for (uint256 i = 0; i < len; ++i) {
            ids[i] = nfts[i];
            amounts[i] = 1;
        }

        ids[len] = VNH_ID;
        amounts[len] = vnhAmount;

        olpContract.safeBatchTransferFrom(
            msg.sender,
            olpAddress,
            ids,
            amounts,
            ""
        );

        // Register new reward.
        // olpContract.setApprovalForAll(owner(), true);
        // setApprovalForAdmin();
        contests[contestId].registerReward(msg.sender, vnhAmount, nfts);
    }

    function registerStudent(address student, address contestId)
        public
        onlyOwner
    {
        require(
            olpContract.isStudent(student),
            "OLPContestFactory: only role student"
        );
        contests[contestId].register(student);
    }

    function registerBatchStudent(address[] memory students, address contestId)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < students.length; ++i) {
            require(
                olpContract.isStudent(students[i]),
                "OLPContestFactory: only role student"
            );
        }
        contests[contestId].registerBatch(students);
    }

    function getNumberOfContests() public view returns (uint256) {
        return totalContest;
    }

    function getContestants(address contestId)
        public
        view
        returns (address[] memory)
    {
        return contests[contestId].getStudents();
    }

    function getContestantsGrade(address contestId)
        public
        view
        returns (Contest.Result[] memory)
    {
        return contests[contestId].getStudentResults();
    }

    function getAllRewardOf(address contestId)
        public
        view
        returns (uint256, uint256[] memory)
    {
        return (
            contests[contestId].getTotalVnhReward(),
            contests[contestId].getTotalNftReward()
        );
    }
}
