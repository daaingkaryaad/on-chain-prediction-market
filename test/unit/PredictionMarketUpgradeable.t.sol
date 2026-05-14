// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {ERC1967Proxy} from "../../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {PredictionMarketUpgradeable} from "../../src/core/PredictionMarketUpgradeable.sol";
import {PredictionMarketUpgradeableV2} from "../../src/mocks/PredictionMarketUpgradeableV2.sol";

contract PredictionMarketUpgradeableTest is Test {
    PredictionMarketUpgradeable internal implementation;
    PredictionMarketUpgradeable internal market;

    address internal admin = address(this);

    function setUp() public {
        implementation = new PredictionMarketUpgradeable();

        bytes memory initData = abi.encodeWithSelector(
            PredictionMarketUpgradeable.initialize.selector, "Upgradeable ETH Market", address(0x1234), admin
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);

        market = PredictionMarketUpgradeable(address(proxy));
    }

    function testInitializeStoresQuestion() public view {
        assertEq(market.marketQuestion(), "Upgradeable ETH Market");
    }

    function testInitializeStoresCollateralToken() public view {
        assertEq(market.collateralToken(), address(0x1234));
    }

    function testInitializeSetsVersionOne() public view {
        assertEq(market.version(), 1);
    }

    function testInitializeGrantsAdminRole() public view {
        assertTrue(market.hasRole(market.DEFAULT_ADMIN_ROLE(), admin));
    }

    function testInitializeGrantsUpgraderRole() public view {
        assertTrue(market.hasRole(market.UPGRADER_ROLE(), admin));
    }

    function testCannotInitializeTwice() public {
        vm.expectRevert();

        market.initialize("Another Market", address(0x5678), admin);
    }

    function testUpgradeWorks() public {
        PredictionMarketUpgradeableV2 newImplementation = new PredictionMarketUpgradeableV2();

        market.upgradeToAndCall(address(newImplementation), bytes(""));

        PredictionMarketUpgradeableV2 upgraded = PredictionMarketUpgradeableV2(address(market));

        assertEq(upgraded.version(), 2);

        assertEq(upgraded.newFunction(), "upgraded");
    }

    function testNonUpgraderCannotUpgrade() public {
        PredictionMarketUpgradeableV2 newImplementation = new PredictionMarketUpgradeableV2();

        vm.prank(address(0xB0B));

        vm.expectRevert();

        market.upgradeToAndCall(address(newImplementation), bytes(""));
    }
}
