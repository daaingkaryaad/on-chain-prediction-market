// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MarketTypes} from "../core/MarketTypes.sol";

interface IPredictionMarket {
    event SharesPurchased(
        address indexed buyer, MarketTypes.Outcome indexed outcome, uint256 collateralIn, uint256 sharesOut
    );

    event MarketResolved(MarketTypes.Outcome indexed outcome, int256 oracleAnswer);

    event RewardsClaimed(address indexed user, uint256 payout);

    function buyYes(uint256 collateralAmount, uint256 minSharesOut) external returns (uint256 sharesOut);

    function buyNo(uint256 collateralAmount, uint256 minSharesOut) external returns (uint256 sharesOut);

    function resolveMarket() external;

    function claimRewards() external returns (uint256 payout);

    function marketState() external view returns (MarketTypes.MarketState);

    function question() external view returns (string memory);
}
