// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";

import {PredictionMarket} from "../../src/core/PredictionMarket.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {LPToken} from "../../src/tokens/LPToken.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";
import {MockOracleAdapter} from "../../src/oracle/MockOracleAdapter.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";

import {PredictionMarketHandler} from "./PredictionMarketHandler.t.sol";

contract PredictionMarketInvariantTest is StdInvariant, Test {
    PredictionMarket internal market;
    OutcomeToken internal outcomeToken;
    LPToken internal lpToken;
    MockERC20 internal collateralToken;
    MockOracleAdapter internal oracle;
    PredictionMarketHandler internal handler;

    address internal admin = address(this);

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

        handler = new PredictionMarketHandler(market, outcomeToken, lpToken, collateralToken, marketId);

        collateralToken.mint(address(handler), 1_000_000 ether);

        targetContract(address(handler));
    }

    function invariantReservesNeverBecomeZero() public view {
        assertGt(market.yesReserve(), 0);
        assertGt(market.noReserve(), 0);
    }

    function invariantMarketStaysOpenDuringTrading() public view {
        assertEq(uint256(market.marketState()), uint256(MarketTypes.MarketState.Open));
    }

    function invariantCollateralSupplyCoversTrackedBalances() public view {
        uint256 marketBalance = collateralToken.balanceOf(address(market));
        uint256 handlerBalance = collateralToken.balanceOf(address(handler));
        uint256 adminBalance = collateralToken.balanceOf(admin);

        assertLe(marketBalance + handlerBalance + adminBalance, collateralToken.totalSupply());
    }

    function invariantLpSupplyDoesNotExceedTotalCollateralSupply() public view {
        assertLe(lpToken.totalSupply(), collateralToken.totalSupply());
    }

    function invariantOutcomeTokenSupplyDoesNotExceedCollateralSupply() public view {
        uint256 yesTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.Yes);
        uint256 noTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.No);

        uint256 totalOutcomeSupply = outcomeToken.totalSupply(yesTokenId) + outcomeToken.totalSupply(noTokenId);

        assertLe(totalOutcomeSupply, collateralToken.totalSupply());
    }
}
