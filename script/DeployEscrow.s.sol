// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {DecentralizedEscrow} from "../src/DecentralizedEscrow.sol";

contract DeployEscrow is Script {
    DecentralizedEscrow public decentralizedEscrow;

    function setUp() external {}

    function run() external {
        vm.startBroadcast();
        decentralizedEscrow = new DecentralizedEscrow();
        vm.stopBroadcast();
    }
}
