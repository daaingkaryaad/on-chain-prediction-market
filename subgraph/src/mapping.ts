import { BigInt, Bytes, Address } from "@graphprotocol/graph-ts";

import { MarketCreated } from "../generated/PredictionMarketFactory/PredictionMarketFactory";
import { ProposalCreated } from "../generated/ProtocolGovernor/ProtocolGovernor";

import {
  SharesPurchased,
  SharesSold,
  LiquidityAdded,
  LiquidityRemoved,
  MarketResolved,
  RewardsClaimed
} from "../generated/templates/PredictionMarket/PredictionMarket";

import { PredictionMarket as PredictionMarketTemplate } from "../generated/templates";

import {
  Market,
  Trade,
  LiquidityEvent,
  RewardClaim,
  User,
  ProtocolStats,
  GovernanceProposal
} from "../generated/schema";

const PROTOCOL_STATS_ID = "predictx";
const ZERO = BigInt.fromI32(0);
const ZERO_ADDRESS = Bytes.fromHexString("0x0000000000000000000000000000000000000000");

function getProtocolStats(): ProtocolStats {
  let stats = ProtocolStats.load(PROTOCOL_STATS_ID);

  if (stats == null) {
    stats = new ProtocolStats(PROTOCOL_STATS_ID);
    stats.totalMarkets = ZERO;
    stats.totalTrades = ZERO;
    stats.totalVolume = ZERO;
    stats.totalLiquidityAdded = ZERO;
    stats.totalLiquidityRemoved = ZERO;
    stats.totalRewardsClaimed = ZERO;
    stats.save();
  }

  return stats;
}

function getUser(address: Bytes): User {
  let user = User.load(address);

  if (user == null) {
    user = new User(address);
    user.totalTrades = ZERO;
    user.totalBuyVolume = ZERO;
    user.totalSellVolume = ZERO;
    user.totalLiquidityProvided = ZERO;
    user.totalLiquidityRemoved = ZERO;
    user.totalRewardsClaimed = ZERO;
    user.save();
  }

  return user;
}

function getMarketIdFromAddress(address: Address): Bytes {
  return Bytes.fromHexString(address.toHexString());
}

function addressToBytes(address: Address): Bytes {
  return Bytes.fromHexString(address.toHexString());
}

function outcomeToString(outcome: i32): string {
  if (outcome == 1) {
    return "YES";
  }

  if (outcome == 2) {
    return "NO";
  }

  return "UNRESOLVED";
}

export function handleMarketCreated(event: MarketCreated): void {
  let marketId = getMarketIdFromAddress(event.params.market);

  let market = new Market(marketId);
  market.marketAddress = event.params.market;
  market.creator = event.transaction.from;
  market.question = event.params.question;

  market.collateralToken = ZERO_ADDRESS;
  market.outcomeToken = ZERO_ADDRESS;
  market.lpToken = ZERO_ADDRESS;
  market.oracleAdapter = ZERO_ADDRESS;

  market.resolutionTime = ZERO;
  market.initialLiquidity = ZERO;

  market.createdAt = event.block.timestamp;
  market.createdAtBlock = event.block.number;
  market.createdAtTx = event.transaction.hash;

  market.yesVolume = ZERO;
  market.noVolume = ZERO;
  market.totalVolume = ZERO;
  market.liquidityAdded = ZERO;
  market.liquidityRemoved = ZERO;
  market.rewardsClaimed = ZERO;

  market.resolved = false;
  market.winningOutcome = null;
  market.resolvedAt = null;
  market.oracleAnswer = null;

  market.save();

  let stats = getProtocolStats();
  stats.totalMarkets = stats.totalMarkets.plus(BigInt.fromI32(1));
  stats.save();

  PredictionMarketTemplate.create(event.params.market);
}

export function handleSharesPurchased(event: SharesPurchased): void {
  let marketId = getMarketIdFromAddress(event.address);
  let market = Market.load(marketId);

  if (market == null) {
    return;
  }

  let buyer = event.parameters[0].value.toAddress();
  let outcomeRaw = event.parameters[1].value.toI32();
  let collateralAmount = event.parameters[2].value.toBigInt();
  let sharesOut = event.parameters[3].value.toBigInt();

  let user = getUser(addressToBytes(buyer));
  let tradeId = event.transaction.hash.concatI32(event.logIndex.toI32());
  let outcome = outcomeToString(outcomeRaw);

  let trade = new Trade(tradeId);
  trade.market = marketId;
  trade.trader = user.id;
  trade.outcome = outcome;
  trade.side = "BUY";
  trade.collateralAmount = collateralAmount;
  trade.shareAmount = sharesOut;
  trade.timestamp = event.block.timestamp;
  trade.blockNumber = event.block.number;
  trade.transactionHash = event.transaction.hash;
  trade.save();

  if (outcome == "YES") {
    market.yesVolume = market.yesVolume.plus(collateralAmount);
  } else if (outcome == "NO") {
    market.noVolume = market.noVolume.plus(collateralAmount);
  }

  market.totalVolume = market.totalVolume.plus(collateralAmount);
  market.save();

  user.totalTrades = user.totalTrades.plus(BigInt.fromI32(1));
  user.totalBuyVolume = user.totalBuyVolume.plus(collateralAmount);
  user.save();

  let stats = getProtocolStats();
  stats.totalTrades = stats.totalTrades.plus(BigInt.fromI32(1));
  stats.totalVolume = stats.totalVolume.plus(collateralAmount);
  stats.save();
}

export function handleSharesSold(event: SharesSold): void {
  let marketId = getMarketIdFromAddress(event.address);
  let market = Market.load(marketId);

  if (market == null) {
    return;
  }

  let seller = event.parameters[0].value.toAddress();
  let outcomeRaw = event.parameters[1].value.toI32();
  let shareAmount = event.parameters[2].value.toBigInt();
  let collateralOut = event.parameters[3].value.toBigInt();

  let user = getUser(addressToBytes(seller));
  let tradeId = event.transaction.hash.concatI32(event.logIndex.toI32());
  let outcome = outcomeToString(outcomeRaw);

  let trade = new Trade(tradeId);
  trade.market = marketId;
  trade.trader = user.id;
  trade.outcome = outcome;
  trade.side = "SELL";
  trade.collateralAmount = collateralOut;
  trade.shareAmount = shareAmount;
  trade.timestamp = event.block.timestamp;
  trade.blockNumber = event.block.number;
  trade.transactionHash = event.transaction.hash;
  trade.save();

  market.totalVolume = market.totalVolume.plus(collateralOut);
  market.save();

  user.totalTrades = user.totalTrades.plus(BigInt.fromI32(1));
  user.totalSellVolume = user.totalSellVolume.plus(collateralOut);
  user.save();

  let stats = getProtocolStats();
  stats.totalTrades = stats.totalTrades.plus(BigInt.fromI32(1));
  stats.totalVolume = stats.totalVolume.plus(collateralOut);
  stats.save();
}

export function handleLiquidityAdded(event: LiquidityAdded): void {
  let marketId = getMarketIdFromAddress(event.address);
  let market = Market.load(marketId);

  if (market == null) {
    return;
  }

  let user = getUser(event.params.provider);
  let liquidityEventId = event.transaction.hash.concatI32(event.logIndex.toI32());

  let liquidityEvent = new LiquidityEvent(liquidityEventId);
  liquidityEvent.market = marketId;
  liquidityEvent.provider = user.id;
  liquidityEvent.action = "ADD";
  liquidityEvent.collateralAmount = event.params.collateralAmount;
  liquidityEvent.lpTokenAmount = event.params.lpTokensMinted;
  liquidityEvent.timestamp = event.block.timestamp;
  liquidityEvent.blockNumber = event.block.number;
  liquidityEvent.transactionHash = event.transaction.hash;
  liquidityEvent.save();

  market.liquidityAdded = market.liquidityAdded.plus(event.params.collateralAmount);
  market.save();

  user.totalLiquidityProvided = user.totalLiquidityProvided.plus(event.params.collateralAmount);
  user.save();

  let stats = getProtocolStats();
  stats.totalLiquidityAdded = stats.totalLiquidityAdded.plus(event.params.collateralAmount);
  stats.save();
}

export function handleLiquidityRemoved(event: LiquidityRemoved): void {
  let marketId = getMarketIdFromAddress(event.address);
  let market = Market.load(marketId);

  if (market == null) {
    return;
  }

  let provider = event.parameters[0].value.toAddress();
  let lpTokenAmount = event.parameters[1].value.toBigInt();
  let collateralReturned = event.parameters[2].value.toBigInt();

  let user = getUser(addressToBytes(provider));
  let liquidityEventId = event.transaction.hash.concatI32(event.logIndex.toI32());

  let liquidityEvent = new LiquidityEvent(liquidityEventId);
  liquidityEvent.market = marketId;
  liquidityEvent.provider = user.id;
  liquidityEvent.action = "REMOVE";
  liquidityEvent.collateralAmount = collateralReturned;
  liquidityEvent.lpTokenAmount = lpTokenAmount;
  liquidityEvent.timestamp = event.block.timestamp;
  liquidityEvent.blockNumber = event.block.number;
  liquidityEvent.transactionHash = event.transaction.hash;
  liquidityEvent.save();

  market.liquidityRemoved = market.liquidityRemoved.plus(collateralReturned);
  market.save();

  user.totalLiquidityRemoved = user.totalLiquidityRemoved.plus(collateralReturned);
  user.save();

  let stats = getProtocolStats();
  stats.totalLiquidityRemoved = stats.totalLiquidityRemoved.plus(collateralReturned);
  stats.save();
}

export function handleMarketResolved(event: MarketResolved): void {
  let marketId = getMarketIdFromAddress(event.address);
  let market = Market.load(marketId);

  if (market == null) {
    return;
  }

  market.resolved = true;
  market.winningOutcome = outcomeToString(event.params.outcome);
  market.resolvedAt = event.block.timestamp;
  market.oracleAnswer = event.params.oracleAnswer;
  market.save();
}

export function handleRewardsClaimed(event: RewardsClaimed): void {
  let marketId = getMarketIdFromAddress(event.address);
  let market = Market.load(marketId);

  if (market == null) {
    return;
  }

  let user = getUser(event.params.user);
  let claimId = event.transaction.hash.concatI32(event.logIndex.toI32());

  let claim = new RewardClaim(claimId);
  claim.market = marketId;
  claim.user = user.id;
  claim.payout = event.params.payout;
  claim.timestamp = event.block.timestamp;
  claim.blockNumber = event.block.number;
  claim.transactionHash = event.transaction.hash;
  claim.save();

  market.rewardsClaimed = market.rewardsClaimed.plus(event.params.payout);
  market.save();

  user.totalRewardsClaimed = user.totalRewardsClaimed.plus(event.params.payout);
  user.save();

  let stats = getProtocolStats();
  stats.totalRewardsClaimed = stats.totalRewardsClaimed.plus(event.params.payout);
  stats.save();
}

export function handleProposalCreated(event: ProposalCreated): void {
  let proposalId = event.params.proposalId.toString();

  let proposal = new GovernanceProposal(proposalId);
  proposal.proposalId = event.params.proposalId;
  proposal.proposer = event.params.proposer;
  proposal.description = event.params.description;
  proposal.voteStart = event.params.voteStart;
  proposal.voteEnd = event.params.voteEnd;
  proposal.createdAt = event.block.timestamp;
  proposal.createdAtBlock = event.block.number;
  proposal.transactionHash = event.transaction.hash;
  proposal.save();
}