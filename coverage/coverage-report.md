# PredictX Coverage Report

## Overview

Coverage was generated with Foundry using:

```bash
forge coverage
forge test -vvv
```

Foundry includes deployment scripts in the global coverage table. Deployment scripts are not part of the audited smart contract runtime scope, so the assignment-relevant coverage is calculated across the `src/` contract directory.

---

## Test Summary

| Metric | Result |
|---|---:|
| Total Tests | 172 |
| Failed Tests | 0 |
| Skipped Tests | 0 |

---

## Assignment-Relevant Coverage

Coverage across `src/` contracts:

| Metric | Result |
|---|---:|
| Covered Lines | 319 |
| Total Lines | 349 |
| Line Coverage | 91.4% |

This satisfies the required `≥90%` contract line coverage threshold.

---

## Foundry Global Coverage

Foundry global coverage includes deployment scripts under `script/` and test/helper contracts. These files are useful for deployment and testing, but they are not part of the audited runtime protocol scope.

| Metric | Result |
|---|---:|
| Global Line Coverage | 78.44% |
| Global Statement Coverage | 72.36% |
| Global Branch Coverage | 43.88% |
| Global Function Coverage | 92.22% |

The global line coverage is lower mainly because the following deployment scripts are included with `0%` coverage:

- `script/Deploy.s.sol`
- `script/DeployMocks.s.sol`
- `script/VerifyDeployment.s.sol`

## Assignment-Relevant Coverage

The assignment-relevant metric is calculated across Solidity contracts under `src/`, excluding deployment scripts under `script/`.

| Metric | Result |
|---|---:|
| Covered Lines | 319 |
| Total Lines | 349 |
| Line Coverage | 91.40% |

Calculation:

```text
319 covered lines / 349 total lines = 91.40%
```
---

## Contract Coverage Table

| Contract | Line Coverage | Function Coverage |
|---|---:|---:|
| `PredictionMarket.sol` | 91.54% | 100.00% |
| `PredictionMarketFactory.sol` | 100.00% | 100.00% |
| `PredictionMarketUpgradeable.sol` | 87.50% | 100.00% |
| `ProtocolGovernor.sol` | 80.95% | 80.00% |
| `AMMMath.sol` | 100.00% | 100.00% |
| `YulMath.sol` | 87.50% | 100.00% |
| `MockChainlinkAggregator.sol` | 72.22% | 80.00% |
| `MockERC20.sol` | 100.00% | 100.00% |
| `MockGovernanceTarget.sol` | 100.00% | 100.00% |
| `PredictionMarketUpgradeableV2.sol` | 100.00% | 100.00% |
| `ChainlinkOracleAdapter.sol` | 80.95% | 100.00% |
| `MockOracleAdapter.sol` | 100.00% | 100.00% |
| `GovernanceToken.sol` | 100.00% | 100.00% |
| `LPToken.sol` | 100.00% | 100.00% |
| `OutcomeToken.sol` | 86.36% | 83.33% |
| `FeeVault.sol` | 100.00% | 100.00% |

---

## Test Categories

The test suite includes:

- Unit tests
- Fuzz tests
- Invariant tests
- Fork tests
- Gas tests
- Governance lifecycle tests
- Upgradeability tests

## CI Validation

Coverage is also generated in GitHub Actions as part of the `Contracts and Slither` job.

The CI pipeline runs:

```bash
forge fmt --check
forge build --sizes
forge test -vvv
forge snapshot
forge coverage
slither . --config-file slither.config.json
```
---

## Conclusion

The PredictX smart contract suite passes all tests and satisfies the required contract coverage threshold.

| Metric | Result |
|---|---:|
| Tests Passed | 172 |
| Failed Tests | 0 |
| Skipped Tests | 0 |
| `src/` Line Coverage | 91.4% |