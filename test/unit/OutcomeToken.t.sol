// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";

contract OutcomeTokenTest is Test {
    OutcomeToken internal token;

    address internal admin = address(0xA11CE);
    address internal user = address(0xB0B);
    address internal operator = address(0xCAFE);

    bytes32 internal marketId = keccak256("ETH_ABOVE_5000");

    function setUp() public {
        token = new OutcomeToken(admin, "ipfs://predictx/{id}.json");
    }

    function testAdminHasDefaultAdminRole() public view {
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
    }

    function testAdminHasMinterRole() public view {
        assertTrue(token.hasRole(token.MINTER_ROLE(), admin));
    }

    function testTokenIdDiffersForYesAndNo() public view {
        uint256 yesId = token.tokenId(marketId, MarketTypes.Outcome.Yes);
        uint256 noId = token.tokenId(marketId, MarketTypes.Outcome.No);

        assertNotEq(yesId, noId);
    }

    function testTokenIdDiffersAcrossMarkets() public view {
        uint256 firstId = token.tokenId(marketId, MarketTypes.Outcome.Yes);
        uint256 secondId = token.tokenId(keccak256("BTC_ABOVE_120000"), MarketTypes.Outcome.Yes);

        assertNotEq(firstId, secondId);
    }

    function testMintWorksForMinterRole() public {
        vm.prank(admin);
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 100 ether, "");

        uint256 yesId = token.tokenId(marketId, MarketTypes.Outcome.Yes);
        assertEq(token.balanceOf(user, yesId), 100 ether);
    }

    function testMintRevertsForNonMinter() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 100 ether, "");
    }

    function testMintRevertsForZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(OutcomeToken.ZeroAddress.selector);
        token.mint(address(0), marketId, MarketTypes.Outcome.Yes, 100 ether, "");
    }

    function testMintRevertsForZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(OutcomeToken.ZeroAmount.selector);
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 0, "");
    }

    function testBurnWorksForOwner() public {
        vm.prank(admin);
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 100 ether, "");

        vm.prank(user);
        token.burn(user, marketId, MarketTypes.Outcome.Yes, 40 ether);

        uint256 yesId = token.tokenId(marketId, MarketTypes.Outcome.Yes);
        assertEq(token.balanceOf(user, yesId), 60 ether);
    }

    function testBurnWorksForApprovedOperator() public {
        vm.prank(admin);
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 100 ether, "");

        vm.prank(user);
        token.setApprovalForAll(operator, true);

        vm.prank(operator);
        token.burn(user, marketId, MarketTypes.Outcome.Yes, 25 ether);

        uint256 yesId = token.tokenId(marketId, MarketTypes.Outcome.Yes);
        assertEq(token.balanceOf(user, yesId), 75 ether);
    }

    function testBurnWorksForMinterRole() public {
        vm.prank(admin);
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 100 ether, "");

        vm.prank(admin);
        token.burn(user, marketId, MarketTypes.Outcome.Yes, 10 ether);

        uint256 yesId = token.tokenId(marketId, MarketTypes.Outcome.Yes);
        assertEq(token.balanceOf(user, yesId), 90 ether);
    }

    function testBurnRevertsForUnauthorizedCaller() public {
        vm.prank(admin);
        token.mint(user, marketId, MarketTypes.Outcome.Yes, 100 ether, "");

        vm.prank(operator);
        vm.expectRevert();
        token.burn(user, marketId, MarketTypes.Outcome.Yes, 10 ether);
    }
}
