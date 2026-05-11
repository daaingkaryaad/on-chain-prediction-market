// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

import {OutcomeToken} from "../tokens/OutcomeToken.sol";
import {IOracleAdapter} from "../interfaces/IOracleAdapter.sol";
import {IPredictionMarket} from "../interfaces/IPredictionMarket.sol";
import {AMMMath} from "../libraries/AMMMath.sol";
import {MarketTypes} from "./MarketTypes.sol";

/// @title PredictionMarket
/// @notice Binary prediction market using a CPMM pricing mechanism.
contract PredictionMarket is IPredictionMarket, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    error InvalidState();
    error InvalidAmount();
    error MarketNotEnded();
    error AlreadyClaimed();
    error NotWinningOutcome();

    bytes32 public constant RESOLVER_ROLE = keccak256("RESOLVER_ROLE");

    uint256 public constant FEE_BPS = 30; // 0.3%

    IERC20 public immutable collateralToken;
    OutcomeToken public immutable outcomeToken;
    IOracleAdapter public immutable oracleAdapter;

    bytes32 public immutable marketId;

    string public override question;

    uint256 public resolutionTime;

    uint256 public yesReserve;
    uint256 public noReserve;

    mapping(address => bool) public claimed;

    MarketTypes.MarketState public override marketState;

    MarketTypes.Outcome public winningOutcome;

    constructor(
        bytes32 marketId_,
        string memory question_,
        address collateralToken_,
        address outcomeToken_,
        address oracleAdapter_,
        uint256 resolutionTime_,
        uint256 initialLiquidity_,
        address admin
    ) {
        collateralToken = IERC20(collateralToken_);
        outcomeToken = OutcomeToken(outcomeToken_);
        oracleAdapter = IOracleAdapter(oracleAdapter_);

        marketId = marketId_;
        question = question_;
        resolutionTime = resolutionTime_;

        yesReserve = initialLiquidity_;
        noReserve = initialLiquidity_;

        marketState = MarketTypes.MarketState.Open;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RESOLVER_ROLE, admin);
    }

    function buyYes(uint256 collateralAmount, uint256 minSharesOut)
        external
        override
        nonReentrant
        returns (uint256 sharesOut)
    {
        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        if (collateralAmount == 0) {
            revert InvalidAmount();
        }

        collateralToken.safeTransferFrom(msg.sender, address(this), collateralAmount);

        sharesOut = AMMMath.getAmountOut(collateralAmount, yesReserve, noReserve, FEE_BPS);

        AMMMath.validateSlippage(sharesOut, minSharesOut);

        yesReserve += collateralAmount;
        noReserve -= sharesOut;

        outcomeToken.mint(msg.sender, marketId, MarketTypes.Outcome.Yes, sharesOut, "");

        emit SharesPurchased(msg.sender, MarketTypes.Outcome.Yes, collateralAmount, sharesOut);
    }

    function buyNo(uint256 collateralAmount, uint256 minSharesOut)
        external
        override
        nonReentrant
        returns (uint256 sharesOut)
    {
        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        if (collateralAmount == 0) {
            revert InvalidAmount();
        }

        collateralToken.safeTransferFrom(msg.sender, address(this), collateralAmount);

        sharesOut = AMMMath.getAmountOut(collateralAmount, noReserve, yesReserve, FEE_BPS);

        AMMMath.validateSlippage(sharesOut, minSharesOut);

        noReserve += collateralAmount;
        yesReserve -= sharesOut;

        outcomeToken.mint(msg.sender, marketId, MarketTypes.Outcome.No, sharesOut, "");

        emit SharesPurchased(msg.sender, MarketTypes.Outcome.No, collateralAmount, sharesOut);
    }

    function resolveMarket() external override onlyRole(RESOLVER_ROLE) {
        if (block.timestamp < resolutionTime) {
            revert MarketNotEnded();
        }

        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        MarketTypes.MarketResolution memory resolution = oracleAdapter.getResolution(marketId);

        winningOutcome = resolution.outcome;

        marketState = MarketTypes.MarketState.Resolved;

        emit MarketResolved(resolution.outcome, resolution.oracleAnswer);
    }

    function claimRewards() external override nonReentrant returns (uint256 payout) {
        if (marketState != MarketTypes.MarketState.Resolved) {
            revert InvalidState();
        }

        if (claimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        uint256 winningTokenId = outcomeToken.tokenId(marketId, winningOutcome);

        uint256 winningBalance = outcomeToken.balanceOf(msg.sender, winningTokenId);

        if (winningBalance == 0) {
            revert NotWinningOutcome();
        }

        claimed[msg.sender] = true;

        payout = winningBalance;

        outcomeToken.burn(msg.sender, marketId, winningOutcome, winningBalance);

        collateralToken.safeTransfer(msg.sender, payout);

        emit RewardsClaimed(msg.sender, payout);
    }
}
