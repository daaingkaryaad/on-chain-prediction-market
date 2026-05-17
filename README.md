# PredictX - On-Chain Prediction Market Protocol

## Overview

PredictX is a decentralized prediction market protocol deployed on Base Sepolia. The protocol enables users to create, trade, and resolve binary outcome markets using a Constant Product Market Maker (CPMM) model.

Users can:

- Buy and sell YES/NO outcome shares.
- Provide and remove liquidity.
- Receive LP tokens for supplied liquidity.
- Claim rewards after market resolution.
- Participate in decentralized governance through ERC20Votes-based voting.
- Interact with upgradeable smart contracts using a documented UUPS V1 → V2 upgrade path.

The protocol combines DeFi primitives, oracle integrations, governance mechanisms, upgradeability, indexing, and gas-optimized Solidity development into a modular production-oriented architecture.

---

# Team

| Name |
|---|
| Ingkar |
| Ansar |
| Kadirzhan |

---

# Architecture

## Core Smart Contracts

| Contract | Description |
|---|---|
| `PredictionMarket.sol` | Core CPMM-based binary prediction market implementation. |
| `PredictionMarketUpgradeable.sol` | UUPS-upgradeable market implementation with V1 → V2 upgrade path. |
| `PredictionMarketFactory.sol` | Factory contract for market deployment using CREATE and CREATE2. |
| `OutcomeToken.sol` | ERC-1155 outcome share tokenization contract. |
| `LPToken.sol` | ERC-20 liquidity provider token contract. |
| `FeeVault.sol` | ERC-4626 vault used for protocol fee accounting. |
| `GovernanceToken.sol` | ERC20Votes + ERC20Permit governance token. |
| `ProtocolGovernor.sol` | OpenZeppelin Governor implementation. |
| `ProtocolTimelock.sol` | TimelockController enforcing delayed governance execution. |
| `ChainlinkOracleAdapter.sol` | Chainlink price feed adapter with stale-price and round validation. |
| `MockOracleAdapter.sol` | Testnet-compatible oracle adapter for market resolution demos. |

---

## Upgradeable UUPS Proxy

PredictX includes a UUPS upgradeability implementation using OpenZeppelin upgradeable contracts.

### Features

- UUPS proxy upgrade pattern.
- V1 → V2 upgrade path.
- Upgrade authorization through `UPGRADER_ROLE`.
- Initializer protection.
- Double-initialization prevention.
- Upgrade tests covering unauthorized upgrade rejection.

## Prerequisites

- Foundry
- Node.js 20
- npm
- Python 3.11 for Slither
- MetaMask
- Base Sepolia ETH for transactions

## Setup

```bash
git clone https://github.com/daaingkaryaad/on-chain-prediction-market.git
cd on-chain-prediction-market
forge install
forge build
forge test
```
---

## Factory Pattern

`PredictionMarketFactory.sol` supports:

- Standard deployment through `CREATE`.
- Deterministic deployment through `CREATE2`.

### Benefits

- Predictable market addresses.
- Consistent market deployment.
- Easier frontend and subgraph integration.
- Reduced manual deployment risk.

---

## DeFi Primitive: CPMM AMM

PredictX implements a Constant Product Market Maker for binary prediction markets.

```solidity
x * y = k
```

Where:

```x``` = YES reserve

```y``` = NO reserve

```k``` = constant product invariant

### AMM Features
- 0.3% fee.
- Slippage protection.
- YES/NO outcome trading.
- LP token minting.
- Liquidity add/remove flows.
- Reentrancy protection.
- Checks-Effects-Interactions ordering.

---

## Governance

Governance uses the full OpenZeppelin Governor stack:

- ERC20Votes
- ERC20Permit
- Governor
- TimelockController

### Governance Lifecycle

```txt
propose → vote → queue → execute
```

### Governance Parameters

| Parameter | Value |
|---|---|
| Voting Delay | 1 day |
| Voting Period | 1 week |
| Timelock Delay | 2 days |
| Proposal Threshold | 1% |
| Quorum | 4% |

---

## Technical Features

### Yul Assembly Optimizations

The protocol includes isolated Yul assembly helpers in YulMath.sol.

| Function | Purpose |
|---|---|
| `min()` | Minimum comparison |
| `max()` | Maximum comparison |
| `mulDiv()` | Multiplication/division helper |

Yul functions are benchmarked against pure Solidity equivalents using Foundry gas tests.

---

### ERC-4626 Vault

```FeeVault.sol``` implements the ERC-4626 Tokenized Vault Standard.

#### Features
- Share-based accounting.
- Standardized deposit and withdraw behavior.
- Protocol fee accounting.
- Vault asset configuration using deployed collateral token.

### Chainlink Oracle Integration

```ChainlinkOracleAdapter.sol``` integrates Chainlink Data Feeds.

#### Oracle Security Checks
- Stale price validation.
- Incomplete round rejection.
- Future timestamp rejection.
- Invalid zero/negative price rejection.
- answeredInRound >= roundId validation.

```answeredInRound >= roundId```

---

## Security & Audit

### Security Measures

- ReentrancyGuard.
- Checks-Effects-Interactions.
- AccessControl-based authorization.
- SafeERC20 for token interactions.
- Timelock governance execution.
- Slippage protection.
- Oracle staleness checks.
- UUPS upgrade authorization.
- Deterministic deployment validation.

### Static Analysis

The protocol was analyzed using:

- Slither
- Forge Coverage
- Forge Fuzz Testing
- Forge Invariant Testing

### Audit Summary

| Tool | Result |
|---|---|
| Slither | 0 High findings |
| Slither | 0 Medium findings |
| Unit Tests | Passing |
| Fuzz Tests | Passing |
| Invariant Tests | Passing |
| Fork Tests | Passing |
| Post-Deployment Verification | Passing |

Internal audit report:

```/audits/security-audit.md```

---

## Deployment
### Network
| Item | Value |
|---|---|
| Network | `Base Sepolia` |
| Chain ID | `84532` |
| Deployment Status | Completed |
| Verification Status | Completed |


### Verified Contract Addresses

| Contract | Address | Explorer |
|---|---|---|
| GovernanceToken | `0x2F6E705b05BE552D64272B84E85806163B087d03` | [BaseScan](https://sepolia.basescan.org/address/0x2f6e705b05be552d64272b84e85806163b087d03) |
| OutcomeToken | `0xF1E2A7746B6F0909e761888b214433ec7A56C869` | [BaseScan](https://sepolia.basescan.org/address/0xf1e2a7746b6f0909e761888b214433ec7a56c869) |
| LPToken | `0xf7203d68c9ec1d73e1d5c77c78182E31A48ABf3F` | [BaseScan](https://sepolia.basescan.org/address/0xf7203d68c9ec1d73e1d5c77c78182e31a48abf3f) |
| FeeVault | `0x8E7e468e98a02e61eaD523709b82A86304A0E275` | [BaseScan](https://sepolia.basescan.org/address/0x8e7e468e98a02e61ead523709b82a86304a0e275) |
| PredictionMarketFactory | `0xCF2A44203097275a975264a7C61798E12CE700aE` | [BaseScan](https://sepolia.basescan.org/address/0xcf2a44203097275a975264a7c61798e12ce700ae) |
| ProtocolGovernor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` | [BaseScan](https://sepolia.basescan.org/address/0x77b883238bae5511935697b08080a4dd90c9dcf8) |
| ProtocolTimelock | `0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C` | [BaseScan](https://sepolia.basescan.org/address/0x59432a83acf3db27bb11b65a0271f9df9c21074c) |
| MockERC20 | `0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2` | [BaseScan](https://sepolia.basescan.org/address/0xba42aeea2717bb4bdbd7b80e8bedc8b31b6be8d2) |
| MockOracleAdapter | `0x95E9428B717c80fb26588d65C64a4b37E299A8AC` | [BaseScan](https://sepolia.basescan.org/address/0x95e9428b717c80fb26588d65c64a4b37e299a8ac) |

Full deployment registry:

```/deployments/addresses.md```

---

## Testing & Coverage

### Test Types

| Test Type | Description |
|---|---|
| Unit Tests | Functional correctness and revert paths |
| Fuzz Tests | Randomized input validation |
| Invariant Tests | Protocol state invariants |
| Fork Tests | Real mainnet protocol integrations |
| Gas Tests | Gas benchmarking and Yul comparison |
| Upgrade Tests | UUPS V1 → V2 upgrade validation |
| Governance Tests | Full propose → vote → queue → execute lifecycle |


### Current Test Status

| Metric | Result |
|---|---|
| Total Tests | 172 |
| Line Coverage | 91.4% |
| Function Coverage | 92.22% |
| Invariant Failures | 0 |
| Slither High Findings | 0 |
| Slither Medium Findings | 0 |


### Run Tests
```bash
forge test
```
### Run Fork Tests
```bash
forge test --match-path test/fork/* --fork-url $MAINNET_RPC_URL
```
### Run Coverage
```bash
forge coverage
```
### Run Static Analysis
```bash
python3 -m slither . --config-file slither.config.json
```
### Run Gas Snapshot
```bash
forge snapshot
```
### Run Build Size Check
```bash
forge build --sizes
```

---

## Deployment Scripts

### Deploy Mock Contracts
```bash
forge script script/DeployMocks.s.sol:DeployMocks \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
  ```
### Deploy Protocol Contracts
```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
  ```
### Verify Deployment Configuration
```bash
forge script script/VerifyDeployment.s.sol:VerifyDeployment \
  --rpc-url base_sepolia
```
### Expected output:
```
Deployment verification passed.
Governor: 0x77b883238BAe5511935697B08080a4Dd90C9dCF8
Timelock: 0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
Factory: 0xCF2A44203097275a975264a7C61798E12CE700aE
FeeVault: 0x8E7e468e98a02e61eaD523709b82A86304A0E275
```

---

## Environment Variables

Create ```.env``` from ```.env.example.```
```bash
cp .env.example .env
```

Required variables:
```
PRIVATE_KEY=
BASE_SEPOLIA_RPC_URL=
BASESCAN_API_KEY=
MAINNET_RPC_URL=
VITE_CHAIN_ID=84532
VITE_RPC_URL=https://sepolia.base.org
VITE_COLLATERAL_TOKEN_ADDRESS=0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2
VITE_FACTORY_ADDRESS=0xCF2A44203097275a975264a7C61798E12CE700aE
VITE_GOVERNANCE_TOKEN_ADDRESS=0x2F6E705b05BE552D64272B84E85806163B087d03
VITE_GOVERNOR_ADDRESS=0x77b883238BAe5511935697B08080a4Dd90C9dCF8
VITE_TIMELOCK_ADDRESS=0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
VITE_FEE_VAULT_ADDRESS=0x8E7e468e98a02e61eaD523709b82A86304A0E275
VITE_ORACLE_ADDRESS=0x95E9428B717c80fb26588d65C64a4b37E299A8AC
VITE_SUBGRAPH_URL=https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

---

## Frontend & Indexing
### Frontend

Frontend application location:

```/frontend```

### Stack
- React
- TypeScript
- Ethers.js
- MetaMask wallet provider
- Base Sepolia
- The Graph subgraph endpoint

### Start Frontend
```bash
cd frontend
npm ci
npm run dev
```

### Set up Subgraph
```bash
cd subgraph
npm ci
npm run codegen
npm run build
```

### Implemented Frontend Features

- MetaMask wallet connection.
- Base Sepolia network detection.
- Wrong-network warning and switch prompt.
- Collateral token balance display.
- Governance token balance display.
- Voting power display.
- Delegate address display.
- Vault shares and managed assets display.
- Mock collateral minting.
- ERC20 approve + ERC4626 vault deposit flow.
- Governance vote delegation.
- Governance proposal list from The Graph.
- On-chain proposal state loading by `proposalId`.
- Vote option selector and vote submission control for Active proposals.
- Transaction and network error messages.

### Subgraph

Graph indexing configuration:

```/subgraph```

Subgraph endpoint:

```text
https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

Indexed entities:

- Market
- Trade
- LiquidityPosition
- Proposal
- UserPosition

Required GraphQL queries are documented in the subgraph documentation.

---

## CI/CD

GitHub Actions runs on every `push` and `pull_request`.

Pipeline jobs:

### Contracts and Slither

```bash
forge fmt --check
forge build --sizes
forge test -vvv
forge snapshot
forge coverage
slither . --config-file slither.config.json
```

Pipeline file:
```
.github/workflows/ci.yml
```
---

## Repository Structure

```text
.
├── src/
│   ├── core/
│   ├── governance/
│   ├── interfaces/
│   ├── libraries/
│   ├── mocks/
│   ├── oracle/
│   ├── tokens/
│   └── vault/
├── test/
│   ├── fork/
│   ├── fuzz/
│   ├── gas/
│   ├── invariant/
│   └── unit/
├── script/
├── frontend/
├── subgraph/
├── audits/
├── gas-reports/
├── deployments/
├── docs/
└── .github/workflows/
```

---

## Build Instructions
### Install Dependencies
```bash
forge install
```
### Build Contracts
```bash
forge build --sizes
```
### Format Contracts
```bash
forge fmt
```

## Demo Governance Proposal

A demo proposal was created through the deployed `ProtocolGovernor` for frontend governance testing.

| Item | Value |
|---|---|
| Proposal ID | `48314768028055173947546214552902984144812981027415071482929356650676633766421` |
| Governor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` |
| Description | `Demo proposal: read FeeVault total managed assets for PredictX frontend governance testing` |
| Vote Start Block | `41632758` |
| Vote End Block | `41683158` |

The proposal is indexed by The Graph and can be loaded in the frontend by `proposalId`. It demonstrates proposal listing, on-chain state loading, and vote UI integration.

---

## Documentation

| Document | Path |
|---|---|
| Architecture Document | `/docs/architecture.md` |
| Security Audit Report | `/audits/security-audit.md` |
| Gas Report | `/gas-reports/gas-report.md` |
| Deployment Registry | `/deployments/addresses.md` |
| Security Policy | `/SECURITY.md` |
| Contribution Guide | `/CONTRIBUTING.md` |
| Coverage Report | `/coverage/coverage-report.md` |

## License

MIT License