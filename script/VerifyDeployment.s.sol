// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {GovernanceToken} from "../src/tokens/GovernanceToken.sol";
import {ProtocolGovernor} from "../src/governance/ProtocolGovernor.sol";
import {ProtocolTimelock} from "../src/governance/ProtocolTimelock.sol";
import {PredictionMarketFactory} from "../src/core/PredictionMarketFactory.sol";
import {FeeVault} from "../src/vault/FeeVault.sol";
import {OutcomeToken} from "../src/tokens/OutcomeToken.sol";
import {LPToken} from "../src/tokens/LPToken.sol";

contract VerifyDeployment is Script {
    function run() external view {
        address governanceTokenAddress = vm.envAddress("GOVERNANCE_TOKEN");

        address governorAddress = vm.envAddress("GOVERNOR");

        address timelockAddress = vm.envAddress("TIMELOCK");

        address factoryAddress = vm.envAddress("FACTORY");

        address feeVaultAddress = vm.envAddress("FEE_VAULT");

        address outcomeTokenAddress = vm.envAddress("OUTCOME_TOKEN");

        address lpTokenAddress = vm.envAddress("LP_TOKEN");

        GovernanceToken governanceToken = GovernanceToken(governanceTokenAddress);

        ProtocolGovernor governor = ProtocolGovernor(payable(governorAddress));

        ProtocolTimelock timelock = ProtocolTimelock(payable(timelockAddress));

        PredictionMarketFactory factory = PredictionMarketFactory(factoryAddress);

        FeeVault feeVault = FeeVault(feeVaultAddress);

        OutcomeToken outcomeToken = OutcomeToken(outcomeTokenAddress);

        LPToken lpToken = LPToken(lpTokenAddress);

        require(governor.votingDelay() == 7_200, "Invalid voting delay");

        require(governor.votingPeriod() == 50_400, "Invalid voting period");

        require(governor.proposalThreshold() == (governanceToken.totalSupply() * 1) / 100, "Invalid proposal threshold");

        require(timelock.getMinDelay() == 2 days, "Invalid timelock delay");

        require(timelock.hasRole(timelock.PROPOSER_ROLE(), governorAddress), "Governor missing proposer role");

        require(timelock.hasRole(timelock.CANCELLER_ROLE(), governorAddress), "Governor missing canceller role");

        require(
            factory.hasRole(factory.DEFAULT_ADMIN_ROLE(), vm.envAddress("DEPLOYER")), "Factory deployer admin missing"
        );

        require(
            feeVault.hasRole(feeVault.DEFAULT_ADMIN_ROLE(), vm.envAddress("DEPLOYER")),
            "FeeVault deployer admin missing"
        );

        require(
            outcomeToken.hasRole(outcomeToken.DEFAULT_ADMIN_ROLE(), vm.envAddress("DEPLOYER")),
            "OutcomeToken deployer admin missing"
        );

        require(
            lpToken.hasRole(lpToken.DEFAULT_ADMIN_ROLE(), vm.envAddress("DEPLOYER")), "LPToken deployer admin missing"
        );

        console.log("Deployment verification passed.");
        console.log("Governor:", governorAddress);
        console.log("Timelock:", timelockAddress);
        console.log("Factory:", factoryAddress);
        console.log("FeeVault:", feeVaultAddress);
    }
}
