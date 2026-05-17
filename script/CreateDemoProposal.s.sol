// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {GovernanceToken} from "../src/tokens/GovernanceToken.sol";
import {ProtocolGovernor} from "../src/governance/ProtocolGovernor.sol";
import {FeeVault} from "../src/vault/FeeVault.sol";

contract CreateDemoProposal is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address governanceTokenAddress = vm.envAddress("GOVERNANCE_TOKEN");
        address governorAddress = vm.envAddress("GOVERNOR");
        address feeVaultAddress = vm.envAddress("FEE_VAULT");

        GovernanceToken governanceToken = GovernanceToken(governanceTokenAddress);
        ProtocolGovernor governor = ProtocolGovernor(payable(governorAddress));

        vm.startBroadcast(deployerPrivateKey);

        address currentDelegate = governanceToken.delegates(deployer);

        if (currentDelegate != deployer) {
            governanceToken.delegate(deployer);

            console.log("Delegated governance votes to deployer.");
            console.log("Deployer:");
            console.logAddress(deployer);
            console.log("Wait for at least one block, then run this script again.");

            vm.stopBroadcast();
            return;
        }

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = feeVaultAddress;
        values[0] = 0;
        calldatas[0] = abi.encodeCall(FeeVault.totalManagedAssets, ());

        string memory description =
            "Demo proposal: read FeeVault total managed assets for PredictX frontend governance testing";

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        console.log("Demo proposal created.");
        console.log("Proposal ID:");
        console.logUint(proposalId);
        console.log("Governor:");
        console.logAddress(governorAddress);
        console.log("Target FeeVault:");
        console.logAddress(feeVaultAddress);
        console.log("Proposer:");
        console.logAddress(deployer);

        vm.stopBroadcast();
    }
}
