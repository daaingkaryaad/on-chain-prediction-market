// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PredictionMarket} from "../../src/core/PredictionMarket.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {LPToken} from "../../src/tokens/LPToken.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";
import {MockOracleAdapter} from "../../src/oracle/MockOracleAdapter.sol";

contract PredictionMarketExtraCoverageTest is Test {
    bytes32 internal constant MARKET_ID = keccak256("ETH above 3000?");
    string internal constant QUESTION = "Will ETH close above 3000 USD?";
    uint256 internal constant INITIAL_LIQUIDITY = 1_000 ether;

    MockERC20 internal collateral;
    OutcomeToken internal outcomeToken;
    LPToken internal lpToken;
    MockOracleAdapter internal oracle;
    PredictionMarket internal market;

    address internal admin = address(this);
    address internal user = address(0xB0B);

    function setUp() public {
        collateral = new MockERC20("Mock USDC", "mUSDC", 18, admin);
        outcomeToken = new OutcomeToken(admin, "ipfs://predictx/{id}.json");
        lpToken = new LPToken(admin);
        oracle = new MockOracleAdapter(admin, 1 days);

        market = new PredictionMarket(
            MARKET_ID,
            QUESTION,
            address(collateral),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            block.timestamp + 1 days,
            INITIAL_LIQUIDITY,
            admin
        );

        outcomeToken.grantRole(outcomeToken.MINTER_ROLE(), address(market));
        lpToken.grantRole(lpToken.MINTER_ROLE(), address(market));
    }

    function testConstructorRevertsWithZeroCollateralToken() public {
        vm.expectRevert(PredictionMarket.TransferFailed.selector);

        new PredictionMarket(
            MARKET_ID,
            QUESTION,
            address(0),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            block.timestamp + 1 days,
            INITIAL_LIQUIDITY,
            admin
        );
    }

    function testConstructorRevertsWithZeroOutcomeToken() public {
        vm.expectRevert(PredictionMarket.TransferFailed.selector);

        new PredictionMarket(
            MARKET_ID,
            QUESTION,
            address(collateral),
            address(0),
            address(lpToken),
            address(oracle),
            block.timestamp + 1 days,
            INITIAL_LIQUIDITY,
            admin
        );
    }

    function testConstructorRevertsWithZeroLpToken() public {
        vm.expectRevert(PredictionMarket.TransferFailed.selector);

        new PredictionMarket(
            MARKET_ID,
            QUESTION,
            address(collateral),
            address(outcomeToken),
            address(0),
            address(oracle),
            block.timestamp + 1 days,
            INITIAL_LIQUIDITY,
            admin
        );
    }

    function testConstructorRevertsWithZeroOracleAdapter() public {
        vm.expectRevert(PredictionMarket.TransferFailed.selector);

        new PredictionMarket(
            MARKET_ID,
            QUESTION,
            address(collateral),
            address(outcomeToken),
            address(lpToken),
            address(0),
            block.timestamp + 1 days,
            INITIAL_LIQUIDITY,
            admin
        );
    }

    function testConstructorRevertsWithZeroAdmin() public {
        vm.expectRevert(PredictionMarket.TransferFailed.selector);

        new PredictionMarket(
            MARKET_ID,
            QUESTION,
            address(collateral),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            block.timestamp + 1 days,
            INITIAL_LIQUIDITY,
            address(0)
        );
    }

    function testRemoveLiquidityRevertsWhenTotalLpSupplyIsZero() public {
        vm.prank(user);
        vm.expectRevert(PredictionMarket.InsufficientLiquidity.selector);

        market.removeLiquidity(1);
    }

    function testRemoveLiquidityRevertsWhenCollateralBalanceIsInsufficient() public {
        lpToken.mint(user, 1);

        vm.prank(user);
        vm.expectRevert(PredictionMarket.InsufficientLiquidity.selector);

        market.removeLiquidity(1);
    }

    function testGetMarketReservesAfterExtraLiquidity() public {
        collateral.mint(user, 10 ether);

        vm.startPrank(user);
        collateral.approve(address(market), 10 ether);
        market.addLiquidity(10 ether);
        vm.stopPrank();

        (uint256 yesReserve, uint256 noReserve) = market.getMarketReserves();

        assertEq(yesReserve, INITIAL_LIQUIDITY + 5 ether);
        assertEq(noReserve, INITIAL_LIQUIDITY + 5 ether);
    }

    function testWinningOutcomeIsUnsetBeforeResolution() public view {
        assertEq(uint256(market.winningOutcome()), uint256(MarketTypes.Outcome.Unresolved));
    }
}