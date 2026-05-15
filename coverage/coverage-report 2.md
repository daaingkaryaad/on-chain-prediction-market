# PredictX Coverage Report

## Overview

Coverage was generated with Foundry using:

```bash
forge coverage
```

Foundry includes deployment scripts in the global coverage table. Deployment scripts are not part of the audited smart contract runtime scope, so the assignment-relevant coverage is calculated across the src/ contract directory.

Test Summary
Metric	Result
Total Tests	163
Failed Tests	0
Skipped Tests	0
Assignment-Relevant Coverage

Coverage across src/ contracts:

Metric	Result
Covered Lines	316
Total Lines	349
Line Coverage	90.54%

This satisfies the required ≥90% contract line coverage threshold.

Foundry Global Coverage

Foundry global coverage includes scripts under script/, which are deployment utilities rather than runtime protocol contracts.

Metric	Result
Global Line Coverage	77.80%
Global Statement Coverage	71.98%
Global Branch Coverage	41.84%
Global Function Coverage	92.22%

The global line coverage is lower because the following deployment scripts are included with 0% coverage:

script/Deploy.s.sol
script/DeployMocks.s.sol
script/VerifyDeployment.s.sol
Contract Coverage Table
Contract	Line Coverage	Function Coverage
PredictionMarket.sol	89.23%	100.00%
PredictionMarketFactory.sol	100.00%	100.00%
PredictionMarketUpgradeable.sol	87.50%	100.00%
ProtocolGovernor.sol	80.95%	80.00%
AMMMath.sol	100.00%	100.00%
YulMath.sol	87.50%	100.00%
MockChainlinkAggregator.sol	72.22%	80.00%
MockERC20.sol	100.00%	100.00%
MockGovernanceTarget.sol	100.00%	100.00%
PredictionMarketUpgradeableV2.sol	100.00%	100.00%
ChainlinkOracleAdapter.sol	80.95%	100.00%
MockOracleAdapter.sol	100.00%	100.00%
GovernanceToken.sol	100.00%	100.00%
LPToken.sol	100.00%	100.00%
OutcomeToken.sol	86.36%	83.33%
FeeVault.sol	100.00%	100.00%
Test Categories

The test suite includes:

Unit tests
Fuzz tests
Invariant tests
Fork tests
Gas tests
Governance lifecycle tests
Upgradeability tests
Conclusion

The PredictX smart contract suite passes all tests and satisfies the required contract coverage threshold.

163 tests passed
0 failed
0 skipped
90.54% line coverage across src/