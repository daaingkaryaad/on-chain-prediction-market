// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {MockERC20} from "../src/mocks/MockERC20.sol";
import {MockOracleAdapter} from "../src/oracle/MockOracleAdapter.sol";

contract DeployMocks is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        MockERC20 collateral = new MockERC20("Mock USDC", "mUSDC", 18, deployer);

        MockOracleAdapter oracle = new MockOracleAdapter(deployer, 1 days);

        console.log("MockERC20:", address(collateral));

        console.log("MockOracleAdapter:", address(oracle));

        vm.stopBroadcast();
    }
}
