// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {GovernanceToken} from "../../src/tokens/GovernanceToken.sol";
import {ProtocolGovernor} from "../../src/governance/ProtocolGovernor.sol";
import {ProtocolTimelock} from "../../src/governance/ProtocolTimelock.sol";
import {MockGovernanceTarget} from "../../src/mocks/MockGovernanceTarget.sol";

contract ProtocolGovernorTest is Test {
    GovernanceToken internal token;
    ProtocolTimelock internal timelock;
    ProtocolGovernor internal governor;
    MockGovernanceTarget internal target;

    address internal admin = address(this);
    address internal voter = address(0xB0B);

    function setUp() public {
        token = new GovernanceToken(admin);

        token.mint(voter, 100_000 ether);

        vm.prank(voter);
        token.delegate(voter);

        vm.roll(block.number + 1);

        address[] memory proposers = new address[](0);

        address[] memory executors = new address[](1);
        executors[0] = address(0);

        timelock = new ProtocolTimelock(proposers, executors, admin);

        governor = new ProtocolGovernor(token, timelock);

        target = new MockGovernanceTarget();

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));

        timelock.revokeRole(bytes32(0), admin);
    }

    function testGovernorName() public view {
        assertEq(governor.name(), "PredictX Governor");
    }

    function testVotingDelayIsOneDayInBlocks() public view {
        assertEq(governor.votingDelay(), 7_200);
    }

    function testVotingPeriodIsOneWeekInBlocks() public view {
        assertEq(governor.votingPeriod(), 50_400);
    }

    function testQuorumIsFourPercent() public {
    vm.roll(block.number + 1);

    uint256 expectedQuorum =
        (token.totalSupply() * 4) / 100;

    assertEq(
        governor.quorum(block.number - 1),
        expectedQuorum
    );
}

    function testProposalThresholdIsOnePercent() public view {
        uint256 expectedThreshold = (token.totalSupply() * 1) / 100;

        assertEq(governor.proposalThreshold(), expectedThreshold);
    }

    function testTimelockDelayIsTwoDays() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }

    function testDelegationGivesVotingPower() public view {
        assertEq(token.getVotes(voter), 100_000 ether);
    }

    function testFullGovernanceLifecycle() public {
        address[] memory targets = new address[](1);
        targets[0] = address(target);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSelector(MockGovernanceTarget.setValue.selector, 42);

        string memory description = "Proposal: set mock governance target value to 42";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        assertEq(uint256(governor.state(proposalId)), 0);

        vm.roll(block.number + governor.votingDelay() + 1);

        assertEq(uint256(governor.state(proposalId)), 1);

        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + governor.votingPeriod() + 1);

        assertEq(uint256(governor.state(proposalId)), 4);

        bytes32 descriptionHash = keccak256(bytes(description));

        governor.queue(targets, values, calldatas, descriptionHash);

        assertEq(uint256(governor.state(proposalId)), 5);

        vm.warp(block.timestamp + timelock.getMinDelay() + 1);

        governor.execute(targets, values, calldatas, descriptionHash);

        assertEq(uint256(governor.state(proposalId)), 7);

        assertEq(target.value(), 42);
    }
}
