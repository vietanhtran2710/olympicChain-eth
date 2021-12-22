// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract OLPAccessControl is AccessControl {
    bool isContractSet = false;
    address public PROCESS_CONTRACT_ADDRESS;

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant SPONSOR_ROLE = keccak256("SPONSOR_ROLE");
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant PARENT_ROLE = keccak256("PARENT_ROLE");
    bytes32 public constant PROCESS_CONTRACT_ROLE =
        keccak256("PROCESS_CONTRACT_ROLE");

    function setContract(address _address)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (address)
    {
        require(
            (isContractSet == false) && (_address != address(0)),
            "Only set once"
        );
        grantRole(PROCESS_CONTRACT_ROLE, _address);
        isContractSet = true;
        PROCESS_CONTRACT_ADDRESS = _address;
        return PROCESS_CONTRACT_ADDRESS;
    }

    function getContractAdress() public view returns (address) {
        return PROCESS_CONTRACT_ADDRESS;
    }

    // Add roles.
    // Only default admin can add roles.
    function addSponsor(address _address) public {
        grantRole(SPONSOR_ROLE, _address);
    }

    function addTeacher(address _address) public {
        grantRole(TEACHER_ROLE, _address);
    }

    function addStudent(address _address) public {
        grantRole(STUDENT_ROLE, _address);
    }

    function addParent(address _address) public {
        grantRole(PARENT_ROLE, _address);
    }

    function addBatchSponsor(address[] memory _address) public {
        for(uint256 i = 0; i < _address.length; ++i) {
            grantRole(SPONSOR_ROLE, _address[i]);
        }
    }

    function addBatchTeacher(address[] memory _address) public {
        for(uint256 i = 0; i < _address.length; ++i) {
            grantRole(TEACHER_ROLE, _address[i]);

        }
    }

    function addBatchStudent(address[] memory _address) public {
        for (uint256 i = 0; i < _address.length; ++i) {
            grantRole(STUDENT_ROLE, _address[i]);
        }
    }

    function addBatchParent(address[] memory _address) public {
        for(uint256 i = 0; i < _address.length; ++i) {
            grantRole(PARENT_ROLE, _address[i]);
        }
    }

    // Remove roles.
    // Only default admin can remove roles.
    function removeSponsor(address _address) public {
        revokeRole(SPONSOR_ROLE, _address);
    }

    function removeTeacher(address _address) public {
        revokeRole(TEACHER_ROLE, _address);
    }

    function removeStudent(address _address) public {
        revokeRole(STUDENT_ROLE, _address);
    }

    function removeParent(address _address) public {
        revokeRole(PARENT_ROLE, _address);
    }

    function removeBatchSponsor(address[] memory _address) public {
        for (uint256 i = 0; i < _address.length; ++i) {
            revokeRole(SPONSOR_ROLE, _address[i]);
        }
    }

    function removeBatchTeacher(address[] memory _address) public {
        for (uint256 i = 0; i < _address.length; ++i) {
            revokeRole(TEACHER_ROLE, _address[i]);
        }
    }

    function removeBatchParent(address[] memory _address) public {
        for (uint256 i = 0; i < _address.length; ++i) {
            revokeRole(PARENT_ROLE, _address[i]);
        }
    }

    function removeBatchStudent(address[] memory _address) public {
        for (uint256 i = 0; i < _address.length; ++i) {
            revokeRole(STUDENT_ROLE, _address[i]);
        }
    }

    // Check if account has role.
    function isAdmin(address _address) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function isTeacher(address _address) public view returns (bool) {
        return hasRole(TEACHER_ROLE, _address);
    }

    function isStudent(address _address) public view returns (bool) {
        return hasRole(STUDENT_ROLE, _address);
    }

    function isParent(address _address) public view returns (bool) {
        return hasRole(PARENT_ROLE, _address);
    }

    function isSponsor(address _address) public view returns (bool) {
        return hasRole(SPONSOR_ROLE, _address);
    }
}
