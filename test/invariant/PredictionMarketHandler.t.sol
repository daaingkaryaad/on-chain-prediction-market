// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PredictionMarket} from "../../src/core/PredictionMarket.sol";
import {OutcomeToken} from "../../src/tokens/OutcomeToken.sol";
import {LPToken} from "../../src/tokens/LPToken.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";

contract PredictionMarketHandler is Test {
    PredictionMarket public market;
    OutcomeToken public outcomeToken;
    LPToken public lpToken;
    MockERC20 public collateralToken;

    bytes32 public marketId;

    constructor(
        PredictionMarket market_,
        OutcomeToken outcomeToken_,
        LPToken lpToken_,
        MockERC20 collateralToken_,
        bytes32 marketId_
    ) {
        market = market_;
        outcomeToken = outcomeToken_;
        lpToken = lpToken_;
        collateralToken = collateralToken_;
        marketId = marketId_;

        collateralToken.approve(address(market), type(uint256).max);
    }

    function buyYes(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 25 ether);

        try market.buyYes(amount, 1) {} catch {}
    }

    function buyNo(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 25 ether);

        try market.buyNo(amount, 1) {} catch {}
    }

    function sellYes(uint96 rawAmount) public {
        uint256 yesTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.Yes);
        uint256 balance = outcomeToken.balanceOf(address(this), yesTokenId);

        if (balance == 0) {
            return;
        }

        uint256 amount = bound(uint256(rawAmount), 1, balance);

        try market.sellYes(amount, 1) {} catch {}
    }

    function sellNo(uint96 rawAmount) public {
        uint256 noTokenId = outcomeToken.tokenId(marketId, MarketTypes.Outcome.No);
        uint256 balance = outcomeToken.balanceOf(address(this), noTokenId);

        if (balance == 0) {
            return;
        }

        uint256 amount = bound(uint256(rawAmount), 1, balance);

        try market.sellNo(amount, 1) {} catch {}
    }

    function addLiquidity(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 2 ether, 50 ether);

        try market.addLiquidity(amount) {} catch {}
    }

    function removeLiquidity(uint96 rawAmount) public {
        uint256 balance = lpToken.balanceOf(address(this));

        if (balance == 0) {
            return;
        }

        uint256 maxSafeAmount = balance / 50;

        if (maxSafeAmount == 0) {
            return;
        }

        uint256 amount = bound(uint256(rawAmount), 1, maxSafeAmount);

        try market.removeLiquidity(amount) {} catch {}
    }
}