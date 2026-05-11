// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MarketTypes} from "../core/MarketTypes.sol";

interface IPredictionMarket {
    event SharesPurchased(
        address indexed buyer, MarketTypes.Outcome indexed outcome, uint256 collateralIn, uint256 sharesOut
    );

    event SharesSold(
        address indexed seller, MarketTypes.Outcome indexed outcome, uint256 sharesIn, uint256 collateralOut
    );

    event LiquidityAdded(address indexed provider, uint256 collateralAmount, uint256 lpTokensMinted);

    event LiquidityRemoved(address indexed provider, uint256 lpTokensBurned, uint256 collateralReturned);

    event MarketResolved(MarketTypes.Outcome indexed outcome, int256 oracleAnswer);

    event RewardsClaimed(address indexed user, uint256 payout);

    function buyYes(uint256 collateralAmount, uint256 minSharesOut) external returns (uint256 sharesOut);

    function buyNo(uint256 collateralAmount, uint256 minSharesOut) external returns (uint256 sharesOut);

    function sellYes(uint256 shareAmount, uint256 minCollateralOut) external returns (uint256 collateralOut);

    function sellNo(uint256 shareAmount, uint256 minCollateralOut) external returns (uint256 collateralOut);

    function addLiquidity(uint256 collateralAmount) external returns (uint256 lpTokensMinted);

    function removeLiquidity(uint256 lpTokenAmount) external returns (uint256 collateralReturned);

    function resolveMarket() external;

    function claimRewards() external returns (uint256 payout);

    function getMarketReserves() external view returns (uint256 yesReserve, uint256 noReserve);

    function marketState() external view returns (MarketTypes.MarketState);

    function question() external view returns (string memory);
}
