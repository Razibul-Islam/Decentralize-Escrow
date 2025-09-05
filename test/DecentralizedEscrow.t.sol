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
        vm.deal(user,AMOUNT);
    }

    function testRegisterAsAClient() external {
        vm.prank(user);
        decentralizedEscrow.register(uint8(DecentralizedEscrow.Role.Client));
        (
            DecentralizedEscrow.Role role,
            address userAddress,
            bool isRegister
        ) = decentralizedEscrow.users(user);

        assertEq(uint(role), uint(DecentralizedEscrow.Role.Client));
        assertEq(userAddress, user);
        assertTrue(isRegister);
    }

    function testRegisterAsFreelancer() external {
        vm.prank(user);
        decentralizedEscrow.register(
            uint8(DecentralizedEscrow.Role.Freelancer)
        );
        (
            DecentralizedEscrow.Role role,
            address userAddress,
            bool isRegister
        ) = decentralizedEscrow.users(user);

        assertEq(uint(role), uint(DecentralizedEscrow.Role.Freelancer));
        assertEq(userAddress, user);
        assertTrue(isRegister);
    }

    function testcheckClientRoleOnlyCanCreateProject() external {
        vm.prank(user);
        decentralizedEscrow.register(uint8(DecentralizedEscrow.Role.Client));

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
        assertEq(uint256(status), uint256(DecentralizedEscrow.ProjectStatus.Open));
        assertEq(deadline, deadlines);
    }

    function testcheckFreelancerRoleCallItFail() external {
        vm.prank(user);
        decentralizedEscrow.register(uint8(DecentralizedEscrow.Role.Freelancer));
        uint256 deadline = block.timestamp + 7 days;

        vm.prank(user);
        vm.expectRevert();
        decentralizedEscrow.createProject{value: 1 ether}(1 ether, deadline);
    }
}
