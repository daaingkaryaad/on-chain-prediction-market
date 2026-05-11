// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PredictionMarketFactory} from "../../src/core/PredictionMarketFactory.sol";
import {PredictionMarket} from "../../src/core/PredictionMarket.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {LPToken} from "../../src/tokens/LPToken.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";
import {MockOracleAdapter} from "../../src/oracle/MockOracleAdapter.sol";

contract PredictionMarketFactoryTest is Test {
    PredictionMarketFactory internal factory;
    OutcomeToken internal outcomeToken;
    LPToken internal lpToken;
    MockERC20 internal collateralToken;
    MockOracleAdapter internal oracle;

    address internal admin = address(this);
    address internal stranger = address(0xBAD);

    bytes32 internal marketId = keccak256("ETH_ABOVE_5000");
    string internal question = "Will ETH be above $5,000 by Dec 31, 2026?";
    uint256 internal resolutionTime;

    function setUp() public {
        resolutionTime = block.timestamp + 30 days;

        factory = new PredictionMarketFactory(admin);
        outcomeToken = new OutcomeToken(admin, "ipfs://predictx/{id}.json");
        lpToken = new LPToken(admin);
        collateralToken = new MockERC20("Mock USDC", "mUSDC", 6, admin);
        oracle = new MockOracleAdapter(admin, 1 days);
    }

    function testConstructorGrantsDefaultAdminRole() public view {
        assertTrue(factory.hasRole(factory.DEFAULT_ADMIN_ROLE(), admin));
    }

    function testConstructorGrantsCreatorRole() public view {
        assertTrue(factory.hasRole(factory.CREATOR_ROLE(), admin));
    }

    function testCreateMarketDeploysMarket() public {
        address market = factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );

        assertTrue(market.code.length > 0);
    }

    function testCreateMarketStoresMarketAddress() public {
        address market = factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );

        assertEq(factory.allMarkets(0), market);
    }

    function testCreateMarketIncrementsMarketsCount() public {
        factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );

        assertEq(factory.marketsCount(), 1);
    }

    function testCreateMarketRevertsIfCollateralTokenIsZero() public {
        vm.expectRevert(PredictionMarketFactory.ZeroAddress.selector);

        factory.createMarket(
            marketId,
            question,
            address(0),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );
    }

    function testCreateMarketRevertsIfOutcomeTokenIsZero() public {
        vm.expectRevert(PredictionMarketFactory.ZeroAddress.selector);

        factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(0),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );
    }

    function testCreateMarketRevertsIfLPTokenIsZero() public {
        vm.expectRevert(PredictionMarketFactory.ZeroAddress.selector);

        factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(0),
            address(oracle),
            resolutionTime,
            1_000 ether
        );
    }

    function testCreateMarketRevertsIfOracleAdapterIsZero() public {
        vm.expectRevert(PredictionMarketFactory.ZeroAddress.selector);

        factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(0),
            resolutionTime,
            1_000 ether
        );
    }

    function testCreateMarketRevertsIfInitialLiquidityIsZero() public {
        vm.expectRevert(PredictionMarketFactory.InvalidLiquidity.selector);

        factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            0
        );
    }

    function testCreateMarketRevertsIfCallerLacksCreatorRole() public {
        vm.prank(stranger);
        vm.expectRevert();

        factory.createMarket(
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );
    }

    function testCreateMarketDeterministicDeploysMarket() public {
        bytes32 salt = keccak256("salt-one");

        address market = factory.createMarketDeterministic(
            salt,
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );

        assertTrue(market.code.length > 0);
    }

    function testCreateMarketDeterministicCreatesPredictableAddress() public {
        bytes32 salt = keccak256("salt-two");

        bytes memory bytecode = abi.encodePacked(
            type(PredictionMarket).creationCode,
            abi.encode(
                marketId,
                question,
                address(collateralToken),
                address(outcomeToken),
                address(lpToken),
                address(oracle),
                resolutionTime,
                1_000 ether,
                admin
            )
        );

        address predicted = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(factory), salt, keccak256(bytecode)))))
        );

        address deployed = factory.createMarketDeterministic(
            salt,
            marketId,
            question,
            address(collateralToken),
            address(outcomeToken),
            address(lpToken),
            address(oracle),
            resolutionTime,
            1_000 ether
        );

        assertEq(deployed, predicted);
    }
}
