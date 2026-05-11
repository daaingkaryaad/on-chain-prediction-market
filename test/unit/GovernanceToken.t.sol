// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../../src/tokens/GovernanceToken.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken internal token;

    address internal owner = address(0xA11CE);
    address internal user = address(0xB0B);

    function setUp() public {
        token = new GovernanceToken(owner);
    }

    function testConstructorMintsInitialSupplyToOwner() public view {
        assertEq(token.balanceOf(owner), 1_000_000 ether);
        assertEq(token.totalSupply(), 1_000_000 ether);
    }

    function testOwnerCanMint() public {
        vm.prank(owner);
        token.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 100 ether);
    }

    function testMintRevertsToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(GovernanceToken.ZeroAddress.selector);
        token.mint(address(0), 100 ether);
    }

    function testMintRevertsWithZeroAmount() public {
        vm.prank(owner);
        vm.expectRevert(GovernanceToken.ZeroAmount.selector);
        token.mint(user, 0);
    }

    function testMintRevertsAboveMaxSupply() public {
        uint256 tooMuch = token.MAX_SUPPLY() - token.totalSupply() + 1;

        vm.prank(owner);
        vm.expectRevert();
        token.mint(user, tooMuch);
    }

    function testDelegateGivesVotingPower() public {
        vm.prank(owner);
        token.delegate(owner);

        assertEq(token.getVotes(owner), token.balanceOf(owner));
    }

    function testNonceStartsAtZero() public view {
        assertEq(token.nonces(owner), 0);
    }
}
