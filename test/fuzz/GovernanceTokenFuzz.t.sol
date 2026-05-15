// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {GovernanceToken} from "../../src/tokens/GovernanceToken.sol";

contract GovernanceTokenFuzzTest is Test {
    GovernanceToken internal token;

    address internal voter = address(0xB0B);
    address internal delegatee = address(0xCAFE);

    function setUp() public {
        token = new GovernanceToken(address(this));
    }

    function testFuzzDelegationGivesVotingPower(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1, 100_000 ether);

        token.mint(voter, amount);

        vm.prank(voter);
        token.delegate(voter);

        assertEq(token.getVotes(voter), amount);
    }

    function testFuzzChangingDelegateMovesVotingPower(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1, 100_000 ether);

        token.mint(voter, amount);

        vm.prank(voter);
        token.delegate(voter);

        assertEq(token.getVotes(voter), amount);
        assertEq(token.getVotes(delegatee), 0);

        vm.prank(voter);
        token.delegate(delegatee);

        assertEq(token.getVotes(voter), 0);
        assertEq(token.getVotes(delegatee), amount);
    }
}
