// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PredictionMarket} from "../../src/core/PredictionMarket.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {LPToken} from "../../src/tokens/LPToken.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";
import {MockOracleAdapter} from "../../src/oracle/MockOracleAdapter.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";

contract PredictionMarketFuzzTest is Test {
    PredictionMarket internal market;
    OutcomeToken internal outcomeToken;
    LPToken internal lpToken;
    MockERC20 internal collateralToken;
    MockOracleAdapter internal oracle;

    address internal admin = address(this);
    address internal user = address(0xB0B);

    bytes32 internal marketId = keccak256("ETH_ABOVE_5000");
    string internal marketQuestion = "Will ETH be above $5,000 by Dec 31, 2026?";
    uint256 internal resolutionTime;

    function setUp() public {
        resolutionTime = block.timestamp + 30 days;

        collateralToken = new MockERC20("Mock USDC", "mUSDC", 18, admin);
        outcomeToken = new OutcomeToken(admin, "ipfs://predictx/{id}.json");
        lpToken = new LPToken(admin);
        oracle = new MockOracleAdapter(admin, 1 days);

        market = new PredictionMarket(
            marketId,
            marketQuestion,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether,
            admin
        );

        outcomeToken.grantRole(outcomeToken.MINTER_ROLE(), address(market));
        lpToken.grantRole(lpToken.MINTER_ROLE(), address(market));

        collateralToken.mint(user, 1_000_000 ether);

        vm.prank(user);
        collateralToken.approve(address(market), type(uint256).max);
    }

    function testFuzzBuyYes(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 500 ether);

        vm.prank(user);
        uint256 sharesOut = market.buyYes(amount, 1);

        uint256 yesTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.Yes);

        assertGt(sharesOut, 0);
        assertEq(outcomeToken.balanceOf(user, yesTokenId), sharesOut);
        assertGt(market.yesReserve(), 1_000 ether);
        assertLt(market.noReserve(), 1_000 ether);
    }

    function testFuzzBuyNo(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 500 ether);

        vm.prank(user);
        uint256 sharesOut = market.buyNo(amount, 1);

        uint256 noTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.No);

        assertGt(sharesOut, 0);
        assertEq(outcomeToken.balanceOf(user, noTokenId), sharesOut);
        assertGt(market.noReserve(), 1_000 ether);
        assertLt(market.yesReserve(), 1_000 ether);
    }

    function testFuzzSellYesAfterBuy(uint96 rawAmount, uint8 rawDivisor) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 500 ether);
        uint256 divisor = bound(uint256(rawDivisor), 2, 10);

        vm.prank(user);
        uint256 sharesOut = market.buyYes(amount, 1);

        uint256 sellAmount = sharesOut / divisor;
        vm.assume(sellAmount > 0);

        uint256 balanceBefore = collateralToken.balanceOf(user);

        vm.prank(user);
        uint256 collateralOut = market.sellYes(sellAmount, 1);

        assertGt(collateralOut, 0);
        assertEq(collateralToken.balanceOf(user), balanceBefore + collateralOut);
    }

    function testFuzzSellNoAfterBuy(uint96 rawAmount, uint8 rawDivisor) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 500 ether);
        uint256 divisor = bound(uint256(rawDivisor), 2, 10);

        vm.prank(user);
        uint256 sharesOut = market.buyNo(amount, 1);

        uint256 sellAmount = sharesOut / divisor;
        vm.assume(sellAmount > 0);

        uint256 balanceBefore = collateralToken.balanceOf(user);

        vm.prank(user);
        uint256 collateralOut = market.sellNo(sellAmount, 1);

        assertGt(collateralOut, 0);
        assertEq(collateralToken.balanceOf(user), balanceBefore + collateralOut);
    }

    function testFuzzAddLiquidity(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 2 ether, 500 ether);

        vm.prank(user);
        uint256 minted = market.addLiquidity(amount);

        assertEq(minted, amount);
        assertEq(lpToken.balanceOf(user), amount);
        assertGt(market.yesReserve(), 1_000 ether);
        assertGt(market.noReserve(), 1_000 ether);
    }

    function testFuzzRemoveSmallLiquidity(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 20 ether, 500 ether);

        vm.prank(user);
        uint256 minted = market.addLiquidity(amount);

        uint256 removeAmount = minted / 20;
        vm.assume(removeAmount > 0);

        vm.prank(user);
        uint256 returnedAmount = market.removeLiquidity(removeAmount);

        assertGt(returnedAmount, 0);
        assertEq(lpToken.balanceOf(user), minted - removeAmount);
    }

    function testFuzzBuyYesRevertsWithImpossibleSlippage(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 500 ether);

        vm.prank(user);
        vm.expectRevert();
        market.buyYes(amount, type(uint256).max);
    }

    function testFuzzBuyNoRevertsWithImpossibleSlippage(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 500 ether);

        vm.prank(user);
        vm.expectRevert();
        market.buyNo(amount, type(uint256).max);
    }
}