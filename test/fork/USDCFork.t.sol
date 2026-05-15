// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

interface IERC20MetadataFork {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract USDCForkTest is Test {
    IERC20MetadataFork internal usdc;

    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address internal constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;

    address internal receiver = address(0xB0B);

    bool internal forkConfigured;

    function setUp() public {
        string memory rpcUrl = vm.envOr("MAINNET_RPC_URL", string(""));

        if (bytes(rpcUrl).length == 0) {
            return;
        }

        vm.createSelectFork(rpcUrl);

        forkConfigured = true;

        usdc = IERC20MetadataFork(USDC);
    }

    function testForkReadsUSDCMetadata() public view {
        if (!forkConfigured) {
            return;
        }

        assertEq(usdc.name(), "USD Coin");
        assertEq(usdc.symbol(), "USDC");
        assertEq(usdc.decimals(), 6);
    }

    function testForkReadsUSDCTotalSupply() public view {
        if (!forkConfigured) {
            return;
        }

        assertGt(usdc.totalSupply(), 0);
    }

    function testForkTransfersUSDCFromWhale() public {
        if (!forkConfigured) {
            return;
        }

        uint256 amount = 100e6;

        uint256 whaleBalance = usdc.balanceOf(USDC_WHALE);

        assertGt(whaleBalance, amount);

        vm.prank(USDC_WHALE);
        bool success = usdc.transfer(receiver, amount);

        assertTrue(success);
        assertEq(usdc.balanceOf(receiver), amount);
    }
}
