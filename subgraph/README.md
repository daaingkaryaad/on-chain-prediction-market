# PredictX Subgraph

## Overview

This subgraph indexes the PredictX on-chain prediction market protocol deployed on Base Sepolia.

It tracks:

- Market creation
- YES/NO trades
- Liquidity events
- Reward claims
- User activity
- Protocol statistics
- Governance proposal creation

The subgraph provides a GraphQL API that allows the frontend to query protocol data without scanning raw blockchain events manually.

---

## Deployment

| Item | Value |
|---|---|
| Network | Base Sepolia |
| Chain ID | `84532` |
| Subgraph Name | `predictx-base-sepolia` |
| Version | `v0.0.1` |
| Studio URL | `https://thegraph.com/studio/subgraph/predictx-base-sepolia` |
| Query Endpoint | `https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1` |

Frontend environment variable:

```env
VITE_SUBGRAPH_URL=https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

---

## Network Configuration

| Item | Value |
|---|---|
| Network | Base Sepolia |
| Chain ID | `84532` |
| Factory | `0xCF2A44203097275a975264a7C61798E12CE700aE` |
| Governor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` |
| Start Block | `41546621` |

---

## Indexed Contracts

| Contract | Address | Purpose |
|---|---|---|
| `PredictionMarketFactory` | `0xCF2A44203097275a975264a7C61798E12CE700aE` | Indexes market creation events |
| `ProtocolGovernor` | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` | Indexes governance proposal creation |
| `PredictionMarket` | Dynamic template | Indexes market trading, liquidity, resolution, and claim events |

`PredictionMarket` contracts are indexed dynamically through a data source template after the factory emits `MarketCreated`.

---

## Entities

### Market

Represents one prediction market.

Tracks:

- Market address
- Question
- Collateral token
- Outcome token
- LP token
- Oracle adapter
- Resolution time
- YES volume
- NO volume
- Total volume
- Liquidity added
- Liquidity removed
- Reward claims
- Resolution status
- Winning outcome

### Trade

Represents a YES/NO buy or sell event.

Tracks:

- Trader
- Market
- Outcome
- Side
- Collateral amount
- Share amount
- Timestamp
- Block number
- Transaction hash

### LiquidityEvent

Represents liquidity added or removed from a market.

Tracks:

- Provider
- Market
- Action
- Collateral amount
- LP token amount
- Timestamp
- Block number
- Transaction hash

### RewardClaim

Represents a successful reward claim after market resolution.

Tracks:

- User
- Market
- Payout
- Timestamp
- Block number
- Transaction hash

### User

Aggregates user-level protocol activity.

Tracks:

- Total trades
- Total buy volume
- Total sell volume
- Total liquidity provided
- Total liquidity removed
- Total rewards claimed

### ProtocolStats

Aggregates protocol-level metrics.

Tracks:

- Total markets
- Total trades
- Total volume
- Total liquidity added
- Total liquidity removed
- Total rewards claimed

### GovernanceProposal

Tracks governance proposals emitted by the Governor contract.

Tracks:

- Proposal ID
- Proposer
- Description
- Vote start
- Vote end
- Creation timestamp
- Creation block
- Transaction hash

---

## Setup

Install dependencies:

```bash
cd subgraph
npm install
```

Generate AssemblyScript types:

```bash
npm run codegen
```

Build the subgraph locally:

```bash
npm run build
```

The compiled subgraph is written to:

```text
subgraph/build/subgraph.yaml
```

---

## Deployment Commands

Authenticate with The Graph Studio:

```bash
npx graph auth <DEPLOY_KEY>
```

Deploy the subgraph:

```bash
npx graph deploy predictx-base-sepolia
```

Version label used:

```text
v0.0.1
```

Deployed endpoint:

```text
https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

Do not commit deploy keys. Deploy keys should be treated as private credentials.

---

## GraphQL Query Examples

### Protocol Statistics

```graphql
{
  protocolStats(id: "predictx") {
    totalMarkets
    totalTrades
    totalVolume
    totalLiquidityAdded
    totalLiquidityRemoved
    totalRewardsClaimed
  }
}
```

### Latest Markets

```graphql
{
  markets(first: 10, orderBy: createdAt, orderDirection: desc) {
    id
    marketAddress
    question
    totalVolume
    yesVolume
    noVolume
    resolved
    winningOutcome
    createdAt
  }
}
```

### Latest Trades

```graphql
{
  trades(first: 10, orderBy: timestamp, orderDirection: desc) {
    id
    market {
      question
      marketAddress
    }
    trader {
      id
    }
    outcome
    side
    collateralAmount
    shareAmount
    timestamp
    transactionHash
  }
}
```

### User Activity

```graphql
{
  users(first: 10, orderBy: totalTrades, orderDirection: desc) {
    id
    totalTrades
    totalBuyVolume
    totalSellVolume
    totalLiquidityProvided
    totalLiquidityRemoved
    totalRewardsClaimed
  }
}
```

### Governance Proposals

```graphql
{
  governanceProposals(first: 10, orderBy: createdAt, orderDirection: desc) {
    proposalId
    proposer
    description
    voteStart
    voteEnd
    createdAt
    transactionHash
  }
}
```

### Liquidity Events

```graphql
{
  liquidityEvents(first: 10, orderBy: timestamp, orderDirection: desc) {
    id
    market {
      question
      marketAddress
    }
    provider {
      id
    }
    action
    collateralAmount
    lpTokenAmount
    timestamp
    transactionHash
  }
}
```

---

## Frontend Integration

The React frontend reads the subgraph URL from:

```env
VITE_SUBGRAPH_URL=https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

Frontend components using subgraph data:

- `SubgraphStats`
- `ProposalList`

The frontend uses the subgraph to display:

- Protocol statistics
- Latest indexed markets
- Governance proposal list
- Proposal metadata before voting

---

## Notes

The factory event currently emits:

```solidity
MarketCreated(address indexed market, bytes32 indexed marketId, string question)
```

Because the factory event does not emit collateral token, outcome token, LP token, oracle adapter, resolution time, or initial liquidity, the subgraph initializes those fields with placeholder zero values.

A future factory event can be expanded to include richer metadata if full market configuration indexing is required directly from the factory event.

Current indexed market activity still works through dynamic `PredictionMarket` templates after each market is created.

---

## Validation

Local validation commands:

```bash
npm ci
npm run codegen
npm run build
```

Expected result:

```text
Types generated successfully
Build completed: build/subgraph.yaml
```

Current status:

| Check | Status |
|---|---|
| Codegen | Passing |
| Build | Passing |
| Deployment | Complete |
| Query Endpoint | Available |