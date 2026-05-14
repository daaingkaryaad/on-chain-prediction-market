# PredictX - On-Chain Prediction Market Protocol

## Overview

PredictX is a decentralized prediction market protocol built on Ethereum-compatible networks. The protocol enables users to create, trade, and resolve binary outcome markets using a Constant Product Market Maker (CPMM) model.

Users can:

* Buy and sell YES/NO outcome shares.
* Provide liquidity and earn protocol fees.
* Participate in decentralized governance through on-chain voting.
* Interact with upgradeable smart contracts secured via UUPS proxies and timelock governance.

The protocol combines DeFi primitives, oracle integrations, governance mechanisms, and gas-optimized Solidity development into a modular and production-oriented architecture. Because apparently university projects are no longer satisfied with “Hello World” and now require miniature financial systems.

---

# Team

| Name      |
| --------- |
| Ingkar    |
| Ansar     |
| Kadirzhan |

---

# Architecture

## Core Smart Contracts

| Contract                          | Description                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------ |
| `PredictionMarket.sol`            | Core CPMM-based binary prediction market implementation.                       |
| `PredictionMarketUpgradeable.sol` | UUPS-upgradeable market implementation (V1 → V2 upgrade path).                 |
| `PredictionMarketFactory.sol`     | Factory contract for deterministic market deployment using CREATE and CREATE2. |
| `OutcomeToken.sol`                | ERC-1155 outcome share tokenization contract.                                  |
| `LPToken.sol`                     | ERC-20 liquidity provider token contract.                                      |
| `FeeVault.sol`                    | ERC-4626 vault used for protocol fee accounting and distribution.              |
| `GovernanceToken.sol`             | ERC20Votes governance token with delegation support.                           |
| `ProtocolGovernor.sol`            | OpenZeppelin Governor implementation for decentralized governance.             |
| `ProtocolTimelock.sol`            | TimelockController enforcing governance execution delays.                      |
| `ChainlinkOracleAdapter.sol`      | Oracle adapter integrating Chainlink price feeds and stale-price validation.   |

---

## Upgradeable UUPS Proxy

The protocol implements the UUPS (Universal Upgradeable Proxy Standard) pattern using OpenZeppelin upgradeable contracts.

### Features

* Proxy-based upgradeability.
* Upgrade authorization via role-based access control.
* Upgrade validation through governance-controlled execution.
* Versioned implementation contracts (`V1 → V2`).

### Security Measures

* `_authorizeUpgrade()` restricted via `UPGRADER_ROLE`.
* Initializer protection (`initializer` modifier).
* Double-initialization prevention.
* Storage-safe inheritance layout.

---

## Factory Pattern

`PredictionMarketFactory.sol` supports:

* Standard deployment via `CREATE`.
* Deterministic deployment via `CREATE2`.

### Benefits

* Predictable market addresses.
* Gas-efficient deployment architecture.
* Permissionless market creation flow.
* Reduced deployment duplication.

---

## DeFi Primitive

PredictX implements a CPMM-based Automated Market Maker (AMM).

### Formula

```solidity
x * y = k
```

Where:

* `x` = YES reserve
* `y` = NO reserve
* `k` = invariant constant

### Features

* Slippage protection.
* Liquidity provision/removal.
* Dynamic pricing.
* Reserve balancing.
* Fee accrual mechanism.
* Reentrancy protection.
* CEI (Checks-Effects-Interactions) ordering.

---

## Governance

Governance is implemented using:

* `ERC20Votes`
* `Governor`
* `TimelockController`

### Governance Flow

1. Proposal creation.
2. Voting delay.
3. Voting period.
4. Proposal queueing.
5. Timelock delay.
6. On-chain execution.

### Governance Parameters

| Parameter          | Value  |
| ------------------ | ------ |
| Voting Delay       | 1 day  |
| Voting Period      | 7 days |
| Timelock Delay     | 2 days |
| Proposal Threshold | 1%     |
| Quorum             | 4%     |

---

# Technical Features

## Yul Assembly Optimizations

The protocol includes gas-optimized inline assembly implementations:

| Function   | Purpose                                      |
| ---------- | -------------------------------------------- |
| `min()`    | Gas-efficient minimum comparison             |
| `max()`    | Gas-efficient maximum comparison             |
| `mulDiv()` | Optimized multiplication/division operations |

Gas benchmarking is implemented through Foundry gas snapshot testing.

---

## ERC-4626 Vault

`FeeVault.sol` implements the ERC-4626 Tokenized Vault Standard.

### Features

* Yield-bearing fee accounting.
* Share-based accounting model.
* Standardized vault interactions.
* Governance-compatible treasury management.

---

## Chainlink Oracle Integration

`ChainlinkOracleAdapter.sol` integrates Chainlink Data Feeds.

### Security Features

* Stale price validation.
* Round completeness validation.
* Future timestamp protection.
* Invalid price rejection.

### Oracle Validation

```solidity
answeredInRound >= roundId
```

---

# Security & Audit

## Security Measures

* ReentrancyGuard.
* AccessControl-based authorization.
* Timelock governance execution.
* Slippage protection.
* Oracle staleness checks.
* CEI-compliant state transitions.
* Upgrade authorization control.

---

## Static Analysis

The protocol was analyzed using:

* Slither
* Forge Coverage
* Forge Invariant Testing
* Forge Fuzz Testing

### Audit Summary

| Tool              | Result                  |
| ----------------- | ----------------------- |
| Slither           | 0 High findings         |
| Slither           | 0 Medium findings       |
| Forge Coverage    | > 90% function coverage |
| Invariant Testing | Passed                  |
| Fuzz Testing      | Passed                  |

Internal audit report:

```text
/audits/security-audit.md
```

---

# Deployment

## Network

**Target Network:** Arbitrum Sepolia

## Verified Contract Addresses

| Contract                    | Address |
| --------------------------- | ------- |
| GovernanceToken             | `TBD`   |
| OutcomeToken                | `TBD`   |
| LPToken                     | `TBD`   |
| FeeVault                    | `TBD`   |
| PredictionMarketFactory     | `TBD`   |
| ProtocolGovernor            | `TBD`   |
| ProtocolTimelock            | `TBD`   |
| ChainlinkOracleAdapter      | `TBD`   |
| PredictionMarketUpgradeable | `TBD`   |

---

# Testing & Coverage

## Test Types

| Test Type       | Description                            |
| --------------- | -------------------------------------- |
| Unit Tests      | Functional correctness                 |
| Fuzz Tests      | Randomized input validation            |
| Invariant Tests | Protocol state invariants              |
| Fork Tests      | Mainnet-compatible behavior validation |

---

## Run Tests

```bash
forge test
```

## Run Coverage

```bash
forge coverage
```

## Run Static Analysis

```bash
python3 -m slither . --config-file slither.config.json
```

## Run Gas Snapshot

```bash
forge snapshot
```

---

# Frontend & Indexing

## Frontend

Frontend application location:

```text
/frontend
```

### Start Frontend

```bash
npm install
npm run dev
```

### Features

* Wallet connection.
* Market trading interface.
* Governance voting dashboard.
* Liquidity management.
* Reward claiming.

---

## Subgraph

Graph indexing configuration:

```text
/subgraph
```

Subgraph endpoint:

```text
TBD
```

Indexed entities:

* Market
* Trade
* LiquidityPosition
* Proposal
* UserPosition

---

# CI/CD

GitHub Actions pipeline automates:

* Solidity formatting checks.
* Contract compilation.
* Unit/Fuzz/Invariant tests.
* Coverage generation.
* Slither security analysis.
* Gas snapshot generation.

Pipeline file:

```text
/.github/workflows/ci.yml
```

---

# Repository Structure

```text
├── src/
├── test/
├── script/
├── frontend/
├── subgraph/
├── audits/
├── gas-reports/
├── docs/
└── .github/workflows/
```

---

# Build Instructions

## Install Dependencies

```bash
forge install
```

## Build Contracts

```bash
forge build --sizes
```

## Format Contracts

```bash
forge fmt
```

---

# License

MIT License
