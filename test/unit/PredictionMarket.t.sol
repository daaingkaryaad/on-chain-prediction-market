// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PredictionMarket} from "../../src/core/PredictionMarket.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";
import {MockOracleAdapter} from "../../src/oracle/MockOracleAdapter.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";

contract PredictionMarketTest is Test {
    PredictionMarket internal market;
    OutcomeToken internal outcomeToken;
    MockERC20 internal collateralToken;
    MockOracleAdapter internal oracle;

    address internal admin = address(this);
    address internal buyer = address(0xB0B);
    address internal stranger = address(0xBAD);

    bytes32 internal marketId = keccak256("ETH_ABOVE_5000");
    string internal marketQuestion = "Will ETH be above $5,000 by Dec 31, 2026?";
    uint256 internal resolutionTime;

    function setUp() public {
        resolutionTime = block.timestamp + 30 days;

        collateralToken = new MockERC20("Mock USDC", "mUSDC", 18, admin);
        outcomeToken = new OutcomeToken(admin, "ipfs://predictx/{id}.json");
        oracle = new MockOracleAdapter(admin, 1 days);

        market = new PredictionMarket(
            marketId,
            marketQuestion,
            address(collateralToken),
            address(outcomeToken),
            address(oracle),
            resolutionTime,
            1_000 ether,
            admin
        );

        outcomeToken.grantRole(outcomeToken.MINTER_ROLE(), address(market));

        collateralToken.mint(buyer, 10_000 ether);

        vm.prank(buyer);
        collateralToken.approve(address(market), type(uint256).max);
    }

    function testConstructorStoresMarketId() public view {
        assertEq(market.marketId(), marketId);
    }

    function testConstructorStoresQuestion() public view {
        assertEq(market.question(), marketQuestion);
    }

    function testConstructorStoresCollateralToken() public view {
        assertEq(address(market.collateralToken()), address(collateralToken));
    }

    function testConstructorStoresOutcomeToken() public view {
        assertEq(address(market.outcomeToken()), address(outcomeToken));
    }

    function testConstructorStoresOracleAdapter() public view {
        assertEq(address(market.oracleAdapter()), address(oracle));
    }

    function testConstructorSetsMarketStateToOpen() public view {
        assertEq(uint256(market.marketState()), uint256(MarketTypes.MarketState.Open));
    }

    function testConstructorSetsYesReserve() public view {
        assertEq(market.yesReserve(), 1_000 ether);
    }

    function testConstructorSetsNoReserve() public view {
        assertEq(market.noReserve(), 1_000 ether);
    }

    function testBuyYesTransfersCollateralFromBuyer() public {
        uint256 buyerBalanceBefore = collateralToken.balanceOf(buyer);

        vm.prank(buyer);
        market.buyYes(100 ether, 1);

        assertEq(collateralToken.balanceOf(buyer), buyerBalanceBefore - 100 ether);
        assertEq(collateralToken.balanceOf(address(market)), 100 ether);
    }

    function testBuyYesMintsYesOutcomeTokens() public {
        vm.prank(buyer);
        uint256 sharesOut = market.buyYes(100 ether, 1);

        uint256 yesTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.Yes);
        assertEq(outcomeToken.balanceOf(buyer, yesTokenId), sharesOut);
    }

    function testBuyYesUpdatesReserves() public {
        uint256 yesBefore = market.yesReserve();
        uint256 noBefore = market.noReserve();

        vm.prank(buyer);
        uint256 sharesOut = market.buyYes(100 ether, 1);

        assertEq(market.yesReserve(), yesBefore + 100 ether);
        assertEq(market.noReserve(), noBefore - sharesOut);
    }

    function testBuyYesRevertsIfAmountIsZero() public {
        vm.prank(buyer);
        vm.expectRevert(PredictionMarket.InvalidAmount.selector);
        market.buyYes(0, 1);
    }

    function testBuyYesRevertsIfSlippageExceeded() public {
        vm.prank(buyer);
        vm.expectRevert();
        market.buyYes(100 ether, 1_000 ether);
    }

    function testBuyNoTransfersCollateralFromBuyer() public {
        uint256 buyerBalanceBefore = collateralToken.balanceOf(buyer);

        vm.prank(buyer);
        market.buyNo(100 ether, 1);

        assertEq(collateralToken.balanceOf(buyer), buyerBalanceBefore - 100 ether);
        assertEq(collateralToken.balanceOf(address(market)), 100 ether);
    }

    function testBuyNoMintsNoOutcomeTokens() public {
        vm.prank(buyer);
        uint256 sharesOut = market.buyNo(100 ether, 1);

        uint256 noTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.No);
        assertEq(outcomeToken.balanceOf(buyer, noTokenId), sharesOut);
    }

    function testBuyNoUpdatesReserves() public {
        uint256 noBefore = market.noReserve();
        uint256 yesBefore = market.yesReserve();

        vm.prank(buyer);
        uint256 sharesOut = market.buyNo(100 ether, 1);

        assertEq(market.noReserve(), noBefore + 100 ether);
        assertEq(market.yesReserve(), yesBefore - sharesOut);
    }

    function testBuyNoRevertsIfAmountIsZero() public {
        vm.prank(buyer);
        vm.expectRevert(PredictionMarket.InvalidAmount.selector);
        market.buyNo(0, 1);
    }

    function testBuyNoRevertsIfSlippageExceeded() public {
        vm.prank(buyer);
        vm.expectRevert();
        market.buyNo(100 ether, 1_000 ether);
    }

    function testResolveMarketRevertsBeforeResolutionTime() public {
        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        vm.expectRevert(PredictionMarket.MarketNotEnded.selector);
        market.resolveMarket();
    }

    function testResolveMarketRevertsIfCallerLacksResolverRole() public {
        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        vm.prank(stranger);
        vm.expectRevert();
        market.resolveMarket();
    }

    function testResolveMarketReadsOracleAndSetsWinningOutcome() public {
        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        assertEq(uint256(market.winningOutcome()), uint256(MarketTypes.Outcome.Yes));
    }

    function testResolveMarketChangesStateToResolved() public {
        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        assertEq(uint256(market.marketState()), uint256(MarketTypes.MarketState.Resolved));
    }

    function testClaimRewardsRevertsBeforeResolution() public {
        vm.prank(buyer);
        market.buyYes(100 ether, 1);

        vm.prank(buyer);
        vm.expectRevert(PredictionMarket.InvalidState.selector);
        market.claimRewards();
    }

    function testClaimRewardsRevertsIfUserHasNoWinningTokens() public {
        vm.prank(buyer);
        market.buyNo(100 ether, 1);

        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        vm.prank(buyer);
        vm.expectRevert(PredictionMarket.NotWinningOutcome.selector);
        market.claimRewards();
    }

    function testClaimRewardsBurnsWinningTokens() public {
        vm.prank(buyer);
        market.buyYes(100 ether, 1);

        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        vm.prank(buyer);
        market.claimRewards();

        uint256 yesTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.Yes);
        assertEq(outcomeToken.balanceOf(buyer, yesTokenId), 0);
    }

    function testClaimRewardsTransfersPayout() public {
        vm.prank(buyer);
        uint256 sharesOut = market.buyYes(100 ether, 1);

        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        uint256 balanceBefore = collateralToken.balanceOf(buyer);

        vm.prank(buyer);
        market.claimRewards();

        assertEq(collateralToken.balanceOf(buyer), balanceBefore + sharesOut);
    }

    function testClaimRewardsMarksUserAsClaimed() public {
        vm.prank(buyer);
        market.buyYes(100 ether, 1);

        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        vm.prank(buyer);
        market.claimRewards();

        assertTrue(market.claimed(buyer));
    }

    function testClaimRewardsRevertsIfCalledTwice() public {
        vm.prank(buyer);
        market.buyYes(100 ether, 1);

        vm.warp(resolutionTime + 1);

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        market.resolveMarket();

        vm.prank(buyer);
        market.claimRewards();

        vm.prank(buyer);
        vm.expectRevert(PredictionMarket.AlreadyClaimed.selector);
        market.claimRewards();
    }
}
