# Contributing to PredictX

Thank you for contributing to PredictX.

This repository contains the smart contract infrastructure, governance system, oracle integrations, testing suite, frontend application, and indexing logic for the PredictX on-chain prediction market protocol.

---

# Development Philosophy

The project prioritizes:

- security-first smart contract engineering
- deterministic deployments
- modular protocol architecture
- extensive automated testing
- governance-controlled upgrades
- gas-aware Solidity development

Contributors are expected to maintain these standards.

---

# Repository Structure

```txt
src/
├── core/
├── governance/
├── interfaces/
├── libraries/
├── mocks/
├── oracle/
├── tokens/
└── vault/

test/
├── fuzz/
├── gas/
├── invariant/
└── unit/

script/
frontend/
subgraph/
````

---

# Requirements

## Tooling

Install:

* Foundry
* Node.js >= 20
* pnpm or npm
* Git

---

## Foundry Installation

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Verify installation:

```bash
forge --version
```

---

# Setup

Clone repository:

```bash
git clone <repository-url>
cd on-chain-prediction-market
```

Install dependencies:

```bash
forge install
npm install
```

---

# Environment Variables

Create a local environment file:

```bash
cp .env.example .env
```

Expected variables:

```env
PRIVATE_KEY=
BASESCAN_API_KEY=
RPC_URL=
```

Never commit private keys or secrets.

Because leaking deployer keys to GitHub is a spectacularly efficient way to speedrun financial regret.

---

# Build

Compile contracts:

```bash
forge build
```

Check formatting:

```bash
forge fmt --check
```

Generate gas snapshots:

```bash
forge snapshot
```

Inspect contract sizes:

```bash
forge build --sizes
```

---

# Testing

Run all tests:

```bash
forge test
```

Run coverage:

```bash
forge coverage
```

Run invariant tests:

```bash
forge test --match-path test/invariant/*
```

Run fuzz tests:

```bash
forge test --match-path test/fuzz/*
```

---

# Security Analysis

Run Slither:

```bash
slither .
```

Expected result:

* 0 High findings
* 0 Medium findings

---

# Solidity Guidelines

## General Rules

* Use Solidity `0.8.24`
* Prefer custom errors over revert strings
* Prefer CEI ordering
* Use OpenZeppelin libraries when applicable
* Minimize storage reads/writes
* Keep contracts modular
* Avoid unnecessary inheritance depth

---

## Security Requirements

All pull requests affecting smart contracts must consider:

* reentrancy
* privilege escalation
* oracle manipulation
* upgrade safety
* governance attacks
* timestamp assumptions
* denial-of-service vectors

---

## Gas Optimization

Gas-sensitive logic should:

* minimize storage writes
* cache storage variables
* use calldata when possible
* avoid redundant external calls
* leverage Yul assembly only when justified

---

# Branch Naming

Use descriptive branch names:

```txt
feature/governance-ui
fix/oracle-validation
refactor/amm-math
test/invariant-suite
```

---

# Commit Convention

Examples:

```txt
feat(governance): add timelock execution tests
fix(oracle): validate answeredInRound
refactor(core): optimize reserve accounting
test(fuzz): add slippage fuzz coverage
docs(readme): update deployment section
```

---

# Pull Requests

Each pull request should include:

* clear summary
* technical rationale
* testing evidence
* security considerations
* screenshots if frontend changes exist

---

# CI Requirements

All pull requests must pass:

* formatting checks
* forge build
* forge test
* forge coverage
* slither analysis

---

# Frontend Development

Start frontend locally:

```bash
cd frontend
npm install
npm run dev
```

---

# Subgraph Development

Generate Graph types:

```bash
cd subgraph
graph codegen
```

Deploy subgraph:

```bash
graph deploy
```

---

# Governance Notes

Protocol upgrades must go through:

1. proposal creation
2. voting period
3. quorum validation
4. timelock queue
5. delayed execution

Direct administrative upgrades are intentionally restricted.

---

# Reporting Issues

When reporting issues include:

* affected contracts
* reproduction steps
* expected behavior
* actual behavior
* logs or traces
* network information

---

# Code Style

Formatting is enforced with:

```bash
forge fmt
```

Do not manually fight the formatter.

The formatter always wins eventually. Humans merely delay the inevitable.

---

# Maintainers

Project maintained by:

* Ingkar
* Ansar
* Kadirzhan

---

# License

MIT
