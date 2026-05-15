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
### Verified Contract Addresses

| Contract | Address | Explorer |
|---|---|---|
| GovernanceToken | `0x2F6E705b05BE552D64272B84E85806163B087d03` | BaseScan |
| OutcomeToken | `0xF1E2A7746B6F0909e761888b214433ec7A56C869` | BaseScan |
| LPToken | `0xf7203d68c9ec1d73e1d5c77c78182E31A48ABf3F` | BaseScan |
| FeeVault | `0x8E7e468e98a02e61eaD523709b82A86304A0E275` | BaseScan |
| PredictionMarketFactory | `0xCF2A44203097275a975264a7C61798E12CE700aE` | BaseScan |
| ProtocolGovernor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` | BaseScan |
| ProtocolTimelock | `0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C` | BaseScan |
| MockERC20 | `0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2` | BaseScan |
| MockOracleAdapter | `0x95E9428B717c80fb26588d65C64a4b37E299A8AC` | BaseScan |

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
| Total Tests | 163 |
| Line Coverage | 90.54% |
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

COLLATERAL_TOKEN=0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2
MOCK_ORACLE=0x95E9428B717c80fb26588d65C64a4b37E299A8AC

GOVERNANCE_TOKEN=0x2F6E705b05BE552D64272B84E85806163B087d03
OUTCOME_TOKEN=0xF1E2A7746B6F0909e761888b214433ec7A56C869
LP_TOKEN=0xf7203d68c9ec1d73e1d5c77c78182E31A48ABf3F
FEE_VAULT=0x8E7e468e98a02e61eaD523709b82A86304A0E275
TIMELOCK=0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
GOVERNOR=0x77b883238BAe5511935697B08080a4Dd90C9dCF8
FACTORY=0xCF2A44203097275a975264a7C61798E12CE700aE
```

Never commit ```.env.```

---

## Frontend & Indexing
### Frontend

Frontend application location:

```/frontend```

### Stack
- React
- Ethers.js / Viem
- Wagmi
- MetaMask wallet connection
- Base Sepolia network detection

### Start Frontend
```bash
cd frontend
npm install
npm run dev
```

### Required Features
- Wallet connection.
- Wrong-network detection.
- Token balance display.
- Voting power display.
- Market reserve display.
- YES/NO trading.
- Liquidity management.
- Governance proposal list.
- Vote button.
- Transaction error handling.

### Subgraph

Graph indexing configuration:

```/subgraph```

Subgraph endpoint:

```TBD```

Indexed entities:

- Market
- Trade
- LiquidityPosition
- Proposal
- UserPosition

Required GraphQL queries are documented in the subgraph documentation.

---

## CI/CD

GitHub Actions pipeline automates:

- forge fmt --check
- forge build --sizes
- forge test
- forge coverage
- forge snapshot
- slither . --config-file slither.config.json

Pipeline file:

```/.github/workflows/ci.yml```

CI runs on:

- push
- pull request

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

## License

MIT License