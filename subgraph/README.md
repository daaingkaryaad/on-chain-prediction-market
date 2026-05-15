# PredictX Subgraph

## Overview

This subgraph indexes the PredictX on-chain prediction market protocol deployed on Base Sepolia.

It tracks:

- market creation
- YES/NO trades
- liquidity events
- reward claims
- user activity
- protocol statistics
- governance proposal creation

---

# Network

| Item | Value |
|---|---|
| Network | Base Sepolia |
| Chain ID | 84532 |
| Factory | `0xCF2A44203097275a975264a7C61798E12CE700aE` |
| Governor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` |
| Start Block | `41546621` |

---

# Entities

## Market

Represents one prediction market.

Tracks:

- market address
- question
- collateral token
- outcome token
- LP token
- oracle adapter
- resolution time
- volume
- liquidity
- resolution status

---

## Trade

Represents a YES/NO buy or sell event.

Tracks:

- trader
- market
- outcome
- side
- collateral amount
- share amount
- transaction hash

---

## LiquidityEvent

Represents liquidity added or removed from a market.

Tracks:

- provider
- action
- collateral amount
- LP token amount
- transaction hash

---

## RewardClaim

Represents a successful reward claim after market resolution.

Tracks:

- user
- market
- payout
- transaction hash

---

## User

Aggregates user-level protocol activity.

Tracks:

- total trades
- buy volume
- sell volume
- liquidity provided
- liquidity removed
- rewards claimed

---

## ProtocolStats

Aggregates protocol-level metrics.

Tracks:

- total markets
- total trades
- total volume
- total liquidity added
- total liquidity removed
- total rewards claimed

---

## GovernanceProposal

Tracks governance proposals emitted by the Governor contract.

Tracks:

- proposal ID
- proposer
- description
- vote start
- vote end
- transaction hash

---

# Setup

Install dependencies:

```bash
cd subgraph
npm install