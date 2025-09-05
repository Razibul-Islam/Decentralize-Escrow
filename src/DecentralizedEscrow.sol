// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract DecentralizedEscrow is ReentrancyGuard {
    error Client__AlreadeyHaveAccount();
    error Freelancer__AlreadeyHaveAccount();
    error Client__CreateProject();

    error Client__DeadLine();
    error Client__Balance();
    error Client__RoleNotMatch();
    error Client__ProjectNotExits();
    error Client__NotProjectOwner();
    error Freelancer__RoleNotMatch();
    error Freelancer_ProjectNotExist();
    error Escrow_StatusNotMatch();
    error Freelancer__NotAssign();
    error Freelancer__DeadlinePassed();
    error Freelancer__SameUser();
    error Client__TransferFailed();

    enum Role {
        Client,
        Freelancer
    }

    enum ProjectStatus {
        Open,
        InProgress,
        Submitted,
        Completed,
        Disputed,
        Resolved
    }

    struct RegisterRole {
        Role role;
        address userAddress;
        bool isRegister;
    }

    struct Project {
        uint256 id;
        address client;
        address freelancer;
        uint256 amount;
        ProjectStatus status;
        uint256 createdAt;
        uint256 deadline;
    }

    mapping(address => bool) public isReg;
    mapping(address => RegisterRole) public users;
    mapping(uint256 => ProjectStatus) public projectsStatus;
    mapping(uint256 => Project) public projects;
    mapping(uint256 => bool) public idExist;

    event UserRegistered(address indexed user, uint256 timestamp, Role role);
    event ProjectCreated(
        address indexed user,
        uint256 indexed id,
        ProjectStatus status,
        uint256 amount
    );
    event AssignProject(
        address indexed freelancer,
        ProjectStatus status,
        uint256 indexed id
    );
    event SubmitProject(address indexed from, address indexed to, uint256 id);
    event ApproveProject(uint256 indexed id);
    event ProjectDisputed(uint256 indexed id);

    address[] clients;
    address[] freelancers;
    uint256 public id;

    function register(uint8 rol) external {
        if (rol == uint8(Role.Client)) {
            registerAsClient();
            emit UserRegistered(msg.sender, block.timestamp, Role.Client);
        } else if (rol == uint8(Role.Freelancer)) {
            registerAsFreelancer();
            emit UserRegistered(msg.sender, block.timestamp, Role.Freelancer);
        }
    }

    function createProject(uint256 amount, uint256 deadline) external payable {
        require(Role.Client == users[msg.sender].role, Client__CreateProject()); // Only Client can create Project
        require(msg.value == amount, Client__Balance()); // Checking Fund of Client
        require(deadline > block.timestamp, Client__DeadLine()); // Checking Deadline
        id = id + 1; // Updateing Project ID
        idExist[id] = true;

        projectsStatus[id] = ProjectStatus.Open;
        projects[id] = Project({
            id: id,
            client: msg.sender,
            freelancer: address(0),
            amount: amount,
            status: ProjectStatus.Open,
            createdAt: block.timestamp,
            deadline: deadline
        });

        emit ProjectCreated(msg.sender, id, ProjectStatus.Open, amount);
    }

    function acceptProject(uint256 projectId) external {
        require(
            Role.Freelancer == users[msg.sender].role,
            Freelancer__RoleNotMatch()
        );
        require(idExist[projectId], Freelancer_ProjectNotExist());
        require(
            ProjectStatus.Open == projects[projectId].status,
            Escrow_StatusNotMatch()
        );
        require(
            msg.sender != projects[projectId].client,
            Freelancer__SameUser()
        );
        require(
            projects[projectId].deadline > block.timestamp,
            Freelancer__DeadlinePassed()
        );

        projects[projectId].status = ProjectStatus.InProgress;
        projects[projectId].freelancer = msg.sender;

        emit AssignProject(msg.sender, ProjectStatus.InProgress, projectId);
    }

    function submitProject(uint256 projectId) external {
        require(
            Role.Freelancer == users[msg.sender].role,
            Freelancer__RoleNotMatch()
        );
        require(idExist[projectId], Freelancer_ProjectNotExist());
        require(
            projects[projectId].freelancer == msg.sender,
            Freelancer__NotAssign()
        );
        require(
            ProjectStatus.InProgress == projects[projectId].status,
            Escrow_StatusNotMatch()
        );
        require(
            projects[projectId].deadline > block.timestamp,
            Freelancer__DeadlinePassed()
        );

        projects[projectId].status = ProjectStatus.Submitted;

        emit SubmitProject(msg.sender, projects[projectId].client, projectId);
    }

    function approveProject(uint256 projectId) external nonReentrant {
        require(Role.Client == users[msg.sender].role, Client__RoleNotMatch());
        require(idExist[projectId], Client__ProjectNotExits());
        require(
            ProjectStatus.Submitted == projects[projectId].status,
            Escrow_StatusNotMatch()
        );
        require(
            projects[projectId].client == msg.sender,
            Client__NotProjectOwner()
        );

        projects[projectId].status = ProjectStatus.Completed;
        (bool success, ) = projects[projectId].freelancer.call{
            value: projects[projectId].amount
        }("");
        require(success, Client__TransferFailed());
        emit ApproveProject(projectId);
    }

    function rejectProject(uint256 projectId) external {
        require(Role.Client == users[msg.sender].role, Client__RoleNotMatch());
        require(idExist[projectId], Client__ProjectNotExits());
        require(
            ProjectStatus.Submitted == projects[projectId].status,
            Escrow_StatusNotMatch()
        );
        require(
            projects[projectId].client == msg.sender,
            Client__NotProjectOwner()
        );

        projects[projectId].status = ProjectStatus.Disputed;
        // Dispute Resolution here

        emit ProjectDisputed(projectId);
    }

    // Internal Functions
    function registerAsClient() internal {
        require(msg.sender != address(0), "Invalid Address");

        if (isReg[msg.sender]) {
            revert Client__AlreadeyHaveAccount();
        }

        users[msg.sender] = RegisterRole({
            role: Role.Client,
            userAddress: msg.sender,
            isRegister: true
        });

        isReg[msg.sender] = true;
        clients.push(msg.sender);
    }

    function registerAsFreelancer() internal {
        require(msg.sender != address(0), "Invalid Address");

        if (isReg[msg.sender]) {
            revert Freelancer__AlreadeyHaveAccount();
        }

        users[msg.sender] = RegisterRole({
            role: Role.Freelancer,
            userAddress: msg.sender,
            isRegister: true
        });

        isReg[msg.sender] = true;
        freelancers.push(msg.sender);
    }
}
