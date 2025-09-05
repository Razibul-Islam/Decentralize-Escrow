// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {DecentralizedEscrow} from "../src/DecentralizedEscrow.sol";

contract TestingDecentralizedEscrow is Test {
    DecentralizedEscrow decentralizedEscrow;
    address user = makeAddr("user");

    uint256 public constant AMOUNT = 2 ether;

    function setUp() public {
        decentralizedEscrow = new DecentralizedEscrow();
        vm.deal(user, AMOUNT);
    }

    modifier RegClient() {
        vm.prank(user);
        decentralizedEscrow.register(uint8(DecentralizedEscrow.Role.Client));
        _;
    }
    modifier RegFreelancer() {
        vm.prank(user);
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );
        _;
    }

    function testRegisterAsAClient() external RegClient {
        (
            DecentralizedEscrow.Role role,
            address userAddress,
            bool isRegister
        ) = decentralizedEscrow.users(user);

        assertEq(uint(role), uint(DecentralizedEscrow.Role.Client));
        assertEq(userAddress, user);
        assertTrue(isRegister);
    }

    function testRegisterAsClientExpectRevertWhenSameUserTryToRegister()
        external
        RegClient
    {
        (
            DecentralizedEscrow.Role role,
            address userAddress,
            bool isRegister
        ) = decentralizedEscrow.users(user);

        assertEq(uint(role), uint(DecentralizedEscrow.Role.Client));
        assertEq(userAddress, user);
        assertTrue(isRegister);

        vm.prank(user);
        vm.expectRevert(
            DecentralizedEscrow.Client__AlreadeyHaveAccount.selector
        );
        decentralizedEscrow.register(uint8(DecentralizedEscrow.Role.Client));
    }

    function testRegisterAsFreelancerExpectRevertWhenSameUserTryToRegister()
        external
        RegFreelancer
    {
        (
            DecentralizedEscrow.Role role,
            address userAddress,
            bool isRegister
        ) = decentralizedEscrow.users(user);

        assertEq(uint(role), uint(DecentralizedEscrow.Role.Freelancer));
        assertEq(userAddress, user);
        assertTrue(isRegister);

        vm.prank(user);
        vm.expectRevert(
            DecentralizedEscrow.Freelancer__AlreadeyHaveAccount.selector
        );
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );
    }

    function testRegisterAsFreelancer() external RegFreelancer {
        (
            DecentralizedEscrow.Role role,
            address userAddress,
            bool isRegister
        ) = decentralizedEscrow.users(user);

        assertEq(uint(role), uint(DecentralizedEscrow.Role.Freelancer));
        assertEq(userAddress, user);
        assertTrue(isRegister);
    }

    function testcheckClientRoleOnlyCanCreateProject() external RegClient {
        uint256 deadline = block.timestamp + 7 days;

        vm.prank(user);
        decentralizedEscrow.createProject{value: 1 ether}(1 ether, deadline);

        (
            uint256 id,
            address client,
            address freelancer,
            uint256 amount,
            DecentralizedEscrow.ProjectStatus status,
            uint256 createdAt,
            uint256 deadlines
        ) = decentralizedEscrow.projects(1);

        assertEq(client, user);
        assertEq(amount, 1 ether);
        assertEq(
            uint256(status),
            uint256(DecentralizedEscrow.ProjectStatus.Open)
        );
        assertEq(deadline, deadlines);
    }

    function testcheckFreelancerRoleCallItFail() external RegFreelancer {
        uint256 deadline = block.timestamp + 7 days;

        vm.prank(user);
        vm.expectRevert();
        decentralizedEscrow.createProject{value: 1 ether}(1 ether, deadline);
    }

    function testSubmitProjectRevertWhenIdDosentExit() external RegFreelancer {
        vm.prank(user);
        vm.expectRevert();
        decentralizedEscrow.submitProject(5);
    }

    function testExpectRevertWhenCheckNotCurrectFreelancer() external {
        address freelancerA = makeAddr("FreelancerA");
        address freelancerB = makeAddr("FreelancerB");
        uint256 deadline = block.timestamp + 7 days;

        vm.prank(freelancerA);
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );

        vm.prank(freelancerB);
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );

        vm.prank(user);
        decentralizedEscrow.createProject{value: 0.5 ether}(
            0.5 ether,
            deadline
        );

        vm.prank(freelancerB);
        vm.expectRevert();
        decentralizedEscrow.submitProject(1);
    }

    function testApproveProjectWhenEverythingIsOkay() external RegClient {
        address freelancer = makeAddr("Freelancer");
        uint256 deadline = block.timestamp + 7 days;

        vm.prank(freelancer);
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );

        vm.prank(user);
        decentralizedEscrow.createProject{value: 0.5 ether}(
            0.5 ether,
            deadline
        );

        vm.prank(freelancer);
        decentralizedEscrow.acceptProject(1);

        vm.prank(freelancer);
        decentralizedEscrow.submitProject(1);

        vm.prank(user);
        decentralizedEscrow.approveProject(1);
    }

    function testRejectProject() external RegClient {
        address freelancer = makeAddr("Freelancer");
        uint256 deadline = block.timestamp + 7 days;

        vm.prank(freelancer);
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );

        vm.prank(user);
        decentralizedEscrow.createProject{value: 0.5 ether}(
            0.5 ether,
            deadline
        );

        vm.prank(freelancer);
        decentralizedEscrow.acceptProject(1);

        vm.prank(freelancer);
        decentralizedEscrow.submitProject(1);

        vm.prank(user);
        decentralizedEscrow.rejectProject(1);
    }
}
