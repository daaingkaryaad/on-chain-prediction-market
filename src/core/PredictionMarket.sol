// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

import {OutcomeToken} from "../tokens/OutcomeToken.sol";
import {LPToken} from "../tokens/LPToken.sol";
import {IOracleAdapter} from "../interfaces/IOracleAdapter.sol";
import {IPredictionMarket} from "../interfaces/IPredictionMarket.sol";
import {AMMMath} from "../libraries/AMMMath.sol";
import {MarketTypes} from "./MarketTypes.sol";

contract PredictionMarket is IPredictionMarket, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    error InvalidState();
    error InvalidAmount();
    error MarketNotEnded();
    error AlreadyClaimed();
    error NotWinningOutcome();
    error InsufficientLiquidity();
    error TransferFailed();

    bytes32 public constant RESOLVER_ROLE = keccak256("RESOLVER_ROLE");

    uint256 public constant FEE_BPS = 30;
    uint256 public constant LIQUIDITY_MULTIPLIER = 2;

    IERC20 public immutable collateralToken;
    OutcomeToken public immutable outcomeToken;
    LPToken public immutable lpToken;
    IOracleAdapter public immutable oracleAdapter;

    bytes32 public immutable marketId;

    string public override question;

    uint256 public immutable resolutionTime;

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
        address lpToken_,
        address oracleAdapter_,
        uint256 resolutionTime_,
        uint256 initialLiquidity_,
        address admin
    ) {
        if (
            collateralToken_ == address(0) || outcomeToken_ == address(0) || lpToken_ == address(0)
                || oracleAdapter_ == address(0) || admin == address(0)
        ) {
            revert TransferFailed();
        }

        collateralToken = IERC20(collateralToken_);
        outcomeToken = OutcomeToken(outcomeToken_);
        lpToken = LPToken(lpToken_);
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

        if (sharesOut >= noReserve) {
            revert InsufficientLiquidity();
        }

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

        if (sharesOut >= yesReserve) {
            revert InsufficientLiquidity();
        }

        noReserve += collateralAmount;
        yesReserve -= sharesOut;

        outcomeToken.mint(msg.sender, marketId, MarketTypes.Outcome.No, sharesOut, "");

        emit SharesPurchased(msg.sender, MarketTypes.Outcome.No, collateralAmount, sharesOut);
    }

    function sellYes(uint256 shareAmount, uint256 minCollateralOut)
        external
        override
        nonReentrant
        returns (uint256 collateralOut)
    {
        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        if (shareAmount == 0) {
            revert InvalidAmount();
        }

        collateralOut = AMMMath.getAmountOut(shareAmount, noReserve, yesReserve, FEE_BPS);

        AMMMath.validateSlippage(collateralOut, minCollateralOut);

        if (collateralOut >= yesReserve) {
            revert InsufficientLiquidity();
        }

        noReserve += shareAmount;
        yesReserve -= collateralOut;

        outcomeToken.burn(msg.sender, marketId, MarketTypes.Outcome.Yes, shareAmount);

        collateralToken.safeTransfer(msg.sender, collateralOut);

        emit SharesSold(msg.sender, MarketTypes.Outcome.Yes, shareAmount, collateralOut);
    }

    function sellNo(uint256 shareAmount, uint256 minCollateralOut)
        external
        override
        nonReentrant
        returns (uint256 collateralOut)
    {
        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        if (shareAmount == 0) {
            revert InvalidAmount();
        }

        collateralOut = AMMMath.getAmountOut(shareAmount, yesReserve, noReserve, FEE_BPS);

        AMMMath.validateSlippage(collateralOut, minCollateralOut);

        if (collateralOut >= noReserve) {
            revert InsufficientLiquidity();
        }

        yesReserve += shareAmount;
        noReserve -= collateralOut;

        outcomeToken.burn(msg.sender, marketId, MarketTypes.Outcome.No, shareAmount);

        collateralToken.safeTransfer(msg.sender, collateralOut);

        emit SharesSold(msg.sender, MarketTypes.Outcome.No, shareAmount, collateralOut);
    }

    function addLiquidity(uint256 collateralAmount) external override nonReentrant returns (uint256 lpTokensMinted) {
        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        if (collateralAmount == 0) {
            revert InvalidAmount();
        }

        collateralToken.safeTransferFrom(msg.sender, address(this), collateralAmount);

        uint256 half = collateralAmount / LIQUIDITY_MULTIPLIER;

        yesReserve += half;
        noReserve += collateralAmount - half;

        lpTokensMinted = collateralAmount;

        lpToken.mint(msg.sender, lpTokensMinted);

        emit LiquidityAdded(msg.sender, collateralAmount, lpTokensMinted);
    }

    function removeLiquidity(uint256 lpTokenAmount)
        external
        override
        nonReentrant
        returns (uint256 collateralReturned)
    {
        if (marketState != MarketTypes.MarketState.Open) {
            revert InvalidState();
        }

        if (lpTokenAmount == 0) {
            revert InvalidAmount();
        }

        uint256 totalLpSupply = lpToken.totalSupply();

        if (totalLpSupply == 0) {
            revert InsufficientLiquidity();
        }

        uint256 yesShare = (yesReserve * lpTokenAmount) / totalLpSupply;
        uint256 noShare = (noReserve * lpTokenAmount) / totalLpSupply;

        collateralReturned = yesShare + noShare;

        if (
            yesShare > yesReserve || noShare > noReserve
                || collateralReturned > collateralToken.balanceOf(address(this))
        ) {
            revert InsufficientLiquidity();
        }

        yesReserve -= yesShare;
        noReserve -= noShare;

        lpToken.burn(msg.sender, lpTokenAmount);

        collateralToken.safeTransfer(msg.sender, collateralReturned);

        emit LiquidityRemoved(msg.sender, lpTokenAmount, collateralReturned);
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

    function getMarketReserves() external view override returns (uint256 currentYesReserve, uint256 currentNoReserve) {
        return (yesReserve, noReserve);
    }
}
