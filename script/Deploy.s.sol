// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {GovernanceToken} from "../src/tokens/GovernanceToken.sol";
import {OutcomeToken} from "../src/tokens/OutcomeToken.sol";
import {LPToken} from "../src/tokens/LPToken.sol";

import {FeeVault} from "../src/vault/FeeVault.sol";

import {ProtocolGovernor} from "../src/governance/ProtocolGovernor.sol";
import {ProtocolTimelock} from "../src/governance/ProtocolTimelock.sol";

import {PredictionMarketFactory} from "../src/core/PredictionMarketFactory.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);

        address collateralTokenAddress = vm.envAddress("COLLATERAL_TOKEN");

        address oracleAddress = vm.envAddress("MOCK_ORACLE");

        vm.startBroadcast(deployerPrivateKey);

        GovernanceToken governanceToken = new GovernanceToken(deployer);

        OutcomeToken outcomeToken = new OutcomeToken(deployer, "ipfs://predictx/{id}.json");

        LPToken lpToken = new LPToken(deployer);

        FeeVault feeVault = new FeeVault(IERC20(collateralTokenAddress), deployer);

        address[] memory proposers = new address[](0);

        address[] memory executors = new address[](1);

        executors[0] = address(0);

        ProtocolTimelock timelock = new ProtocolTimelock(proposers, executors, deployer);

        ProtocolGovernor governor = new ProtocolGovernor(governanceToken, timelock);

        PredictionMarketFactory factory = new PredictionMarketFactory(deployer);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));

        console.log("GovernanceToken:", address(governanceToken));

        console.log("OutcomeToken:", address(outcomeToken));

        console.log("LPToken:", address(lpToken));

        console.log("FeeVault:", address(feeVault));

        console.log("Timelock:", address(timelock));

        console.log("Governor:", address(governor));

        console.log("Factory:", address(factory));

        console.log("CollateralToken:", collateralTokenAddress);

        console.log("Oracle:", oracleAddress);

        vm.stopBroadcast();
    }
}
