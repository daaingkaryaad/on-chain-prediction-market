// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

import {PredictionMarket} from "./PredictionMarket.sol";

/// @title PredictionMarketFactory
/// @notice Factory contract for deploying prediction markets using CREATE and CREATE2.
contract PredictionMarketFactory is AccessControl {
    error ZeroAddress();
    error InvalidLiquidity();

    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    address[] public allMarkets;

    event MarketCreated(address indexed market, bytes32 indexed marketId, string question);

    constructor(address admin) {
        if (admin == address(0)) revert ZeroAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(CREATOR_ROLE, admin);
    }

    function createMarket(
        bytes32 marketId,
        string calldata question,
        address collateralToken,
        address outcomeToken,
        address oracleAdapter,
        uint256 resolutionTime,
        uint256 initialLiquidity
    ) external onlyRole(CREATOR_ROLE) returns (address market) {
        if (collateralToken == address(0) || outcomeToken == address(0) || oracleAdapter == address(0)) {
            revert ZeroAddress();
        }

        if (initialLiquidity == 0) {
            revert InvalidLiquidity();
        }

        market = address(
            new PredictionMarket(
                marketId,
                question,
                collateralToken,
                outcomeToken,
                oracleAdapter,
                resolutionTime,
                initialLiquidity,
                msg.sender
            )
        );

        allMarkets.push(market);

        emit MarketCreated(market, marketId, question);
    }

    function createMarketDeterministic(
        bytes32 salt,
        bytes32 marketId,
        string calldata question,
        address collateralToken,
        address outcomeToken,
        address oracleAdapter,
        uint256 resolutionTime,
        uint256 initialLiquidity
    ) external onlyRole(CREATOR_ROLE) returns (address market) {
        if (collateralToken == address(0) || outcomeToken == address(0) || oracleAdapter == address(0)) {
            revert ZeroAddress();
        }

        if (initialLiquidity == 0) {
            revert InvalidLiquidity();
        }

        market = address(
            new PredictionMarket{salt: salt}(
                marketId,
                question,
                collateralToken,
                outcomeToken,
                oracleAdapter,
                resolutionTime,
                initialLiquidity,
                msg.sender
            )
        );

        allMarkets.push(market);

        emit MarketCreated(market, marketId, question);
    }

    function marketsCount() external view returns (uint256) {
        return allMarkets.length;
    }
}
