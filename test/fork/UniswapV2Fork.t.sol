// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

interface IUniswapV2RouterFork {
    function factory()
        external
        view
        returns (address);

    function WETH()
        external
        view
        returns (address);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    )
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2FactoryFork {
    function getPair(
        address tokenA,
        address tokenB
    )
        external
        view
        returns (address pair);
}

contract UniswapV2ForkTest is Test {
    IUniswapV2RouterFork internal router;
    IUniswapV2FactoryFork internal factory;

    address internal constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address internal constant USDC =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    bool internal forkConfigured;

    function setUp() public {
        string memory rpcUrl =
            vm.envOr("MAINNET_RPC_URL", string(""));

        if (bytes(rpcUrl).length == 0) {
            return;
        }

        vm.createSelectFork(rpcUrl);

        forkConfigured = true;

        router =
            IUniswapV2RouterFork(UNISWAP_V2_ROUTER);

        factory =
            IUniswapV2FactoryFork(router.factory());
    }

    function testForkReadsUniswapRouterAddresses() public view {
        if (!forkConfigured) {
            return;
        }

        assertTrue(router.factory() != address(0));
        assertTrue(router.WETH() != address(0));
    }

    function testForkUniswapPairExistsForWethUsdc() public view {
        if (!forkConfigured) {
            return;
        }

        address pair =
            factory.getPair(
                router.WETH(),
                USDC
            );

        assertTrue(pair != address(0));
    }

    function testForkGetsAmountsOutForWethToUsdc() public view {
        if (!forkConfigured) {
            return;
        }

        address[] memory path =
            new address[](2);

        path[0] = router.WETH();
        path[1] = USDC;

        uint256[] memory amounts =
            router.getAmountsOut(
                1 ether,
                path
            );

        assertEq(amounts.length, 2);
        assertEq(amounts[0], 1 ether);
        assertGt(amounts[1], 0);
    }
}