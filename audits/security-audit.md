# PredictX Internal Security Audit

## Audit Information

| Item | Value |
|---|---|
| Protocol | PredictX |
| Audit Type | Internal Security Review |
| Version | v1.0 |
| Audit Date | 2026 |
| Auditors | Ingkar, Ansar, Kadirzhan |
| Target Network | Base Sepolia |
| Repository | Private Academic Repository |

---

# 1. Executive Summary

PredictX is a decentralized binary prediction market protocol built on Base Sepolia.

The protocol includes:

- CPMM-based AMM trading
- ERC-1155 outcome shares
- ERC-20 LP tokens
- ERC-4626 fee vault
- ERC20Votes governance
- Timelocked governance execution
- UUPS upgradeability
- Chainlink oracle validation
- CREATE and CREATE2 market deployment

The review focused on:

- reentrancy protection
- oracle validation
- access control
- governance execution
- reserve accounting
- upgradeability safety
- liquidity accounting
- reward claiming logic
- deterministic deployment safety

The protocol passed all implemented:

- unit tests
- fuzz tests
- invariant tests
- upgrade tests
- governance lifecycle tests

Final testing metrics:

| Metric | Result |
|---|---|
| Total Tests | 137+ |
| Line Coverage | 91.98% |
| Function Coverage | 96.25% |
| Slither High Findings | 0 |
| Slither Medium Findings | 0 |

---

# 2. Scope

## In-Scope Contracts

| Contract | Purpose |
|---|---|
| PredictionMarket.sol | Core AMM prediction market |
| PredictionMarketFactory.sol | Factory deployment |
| PredictionMarketUpgradeable.sol | UUPS upgradeable implementation |
| ProtocolGovernor.sol | Governance logic |
| ProtocolTimelock.sol | Timelock execution |
| GovernanceToken.sol | ERC20Votes token |
| OutcomeToken.sol | ERC1155 outcome shares |
| LPToken.sol | Liquidity provider token |
| FeeVault.sol | ERC4626 fee vault |
| ChainlinkOracleAdapter.sol | Oracle validation |
| MockOracleAdapter.sol | Testing oracle |
| AMMMath.sol | AMM pricing logic |
| YulMath.sol | Optimized assembly math |

---

## Out-of-Scope

The following were intentionally excluded:

- frontend React application
- subgraph indexing layer
- RPC providers
- external wallet integrations
- Base Sepolia infrastructure
- Chainlink infrastructure internals

---

# 3. Audit Methodology

The audit combined:

## 3.1 Manual Review

Manual inspection focused on:

- privilege escalation
- unsafe external calls
- reserve accounting
- upgradeability risks
- access-control correctness
- CEI ordering
- governance attack vectors
- oracle validation
- arithmetic safety

---

## 3.2 Static Analysis

Tool used:

```text
Slither

Final Slither result:

0 High findings
0 Medium findings

Remaining informational findings:

timestamp usage
OpenZeppelin inherited event indexing notices

These findings were reviewed manually and determined acceptable for protocol behavior.

3.3 Unit Testing

Implemented using:

Foundry

Coverage areas:

market trading
liquidity management
reward claiming
governance lifecycle
upgrade authorization
ERC4626 accounting
oracle validation
access-control enforcement
3.4 Fuzz Testing

Fuzz testing validated:

AMM reserve transitions
slippage bounds
buy/sell consistency
liquidity operations

Fuzz tests executed across randomized inputs.

3.5 Invariant Testing

Invariant testing validated:

reserves never become zero
LP supply accounting
collateral accounting consistency
market state consistency
outcome supply bounds

Invariant runs:

256 runs
128,000 calls per invariant
0 invariant violations
4. System Architecture Security Review
4.1 PredictionMarket.sol
Overview

Main protocol market contract responsible for:

trading
liquidity management
reward claiming
oracle-based resolution
Security Properties
Property	Status
Reentrancy Protection	PASS
Slippage Protection	PASS
CEI Ordering	PASS
Access Control	PASS
Reserve Validation	PASS
SafeERC20 Usage	PASS
Reentrancy Protection

All external state-changing functions use:

nonReentrant

Protected functions:

buyYes()
buyNo()
sellYes()
sellNo()
addLiquidity()
removeLiquidity()
claimRewards()
CEI Ordering

State updates occur before external token transfers.

Example:

claimed[msg.sender] = true;
outcomeToken.burn(...);
collateralToken.safeTransfer(...);

This significantly reduces reentrancy risk.

Slippage Protection

Trading operations enforce user-defined minimum outputs:

AMMMath.validateSlippage(...)

This protects users against:

MEV manipulation
reserve front-running
unexpected reserve imbalance
Reserve Safety

The protocol prevents invalid reserve depletion:

if (sharesOut >= reserve)

and

if (collateralOut >= reserve)

These checks prevent invalid AMM states.

4.2 PredictionMarketFactory.sol
CREATE and CREATE2 Review

The factory supports:

CREATE
CREATE2

CREATE2 deterministic deployment was reviewed for:

salt collision safety
deterministic address correctness
deployment uniqueness

No collision vulnerabilities were identified.

Input Validation

Factory deployment validates:

zero addresses
initial liquidity
role permissions

Unauthorized deployment is prevented through:

CREATOR_ROLE
4.3 Upgradeability Review
UUPS Proxy Security

The upgradeable implementation uses:

UUPSUpgradeable

Upgrade authorization:

onlyRole(UPGRADER_ROLE)
Risks Reviewed
Risk	Result
Unauthorized Upgrade	PASS
Reinitialization	PASS
Storage Collision	PASS
Broken Upgrade Path	PASS
Reinitialization Protection

The initializer uses:

initializer

and rejects repeated initialization.

Upgrade Authorization

Only accounts with:

UPGRADER_ROLE

may upgrade implementations.

Unauthorized upgrades revert correctly.

4.4 Governance Review
Governance Components
Component	Purpose
GovernanceToken	Voting power
ProtocolGovernor	Proposal lifecycle
ProtocolTimelock	Delayed execution
Governance Security

The governance lifecycle was fully tested:

propose → vote → queue → execute

Governance protections:

Mechanism	Purpose
Voting Delay	Prevent flash proposal execution
Voting Period	Allow community participation
Proposal Threshold	Prevent spam proposals
Quorum	Require meaningful participation
Timelock Delay	Delay execution
Governance Attack Review
Flash Loan Governance Attack

Mitigation:

ERC20Votes snapshot checkpointing

Voting power is measured historically.

Instant Malicious Execution

Mitigation:

2-day timelock delay

Users have time to react before execution.

Proposal Spam

Mitigation:

1% proposal threshold
4.5 Oracle Security Review
Oracle Validation

The Chainlink adapter validates:

answeredInRound >= roundId
startedAt != 0
updatedAt != 0
updatedAt <= block.timestamp
price > 0
block.timestamp - updatedAt <= stalePriceDelay
Oracle Risks Reviewed
Risk	Result
Stale Data	PASS
Incomplete Round	PASS
Negative Price	PASS
Future Timestamp	PASS
Invalid Feed Address	PASS
Timestamp Dependence

Slither flagged timestamp usage.

Reviewed timestamp usage:

block.timestamp < resolutionTime
block.timestamp - updatedAt > stalePriceDelay

Assessment:

Accepted.

Reason:

timestamp checks are necessary for market deadlines
oracle freshness inherently requires time-based validation
validator timestamp manipulation range is too small to materially impact the protocol

Severity:

Informational
4.6 ERC4626 Vault Review
FeeVault.sol

The vault implements standardized ERC4626 accounting.

Reviewed properties:

Property	Status
Share Accounting	PASS
Deposit Validation	PASS
Withdraw Accounting	PASS
Access Control	PASS
Inflation Attack Review

The vault does not expose donation-based inflation vulnerabilities because:

deposits are controlled
accounting uses ERC4626 share logic
test coverage validates asset accounting
5. Findings Summary
Final Findings Table
Severity	Count
Critical	0
High	0
Medium	0
Low	0
Informational	5
6. Informational Findings
INFO-01: Timestamp Dependence
Description

Several contracts use:

block.timestamp

for:

market resolution deadlines
oracle freshness validation
Impact

Validators can slightly manipulate timestamps.

Assessment

Accepted.

The manipulation range is insufficient to materially impact protocol behavior.

Status
Acknowledged
INFO-02: OpenZeppelin Event Indexing Notices
Description

Slither flagged inherited OpenZeppelin events with non-indexed addresses.

Assessment

Inherited OpenZeppelin implementation.

No protocol-specific issue exists.

Status
Accepted
7. Gas and Bytecode Review
Contract Size Validation

All contracts remain below:

EIP-170 runtime limit

Largest contract:

ProtocolGovernor.sol
15,535 bytes runtime

EIP-170 limit:

24,576 bytes
Gas Optimization Review

Optimizations identified:

immutable variables
custom errors
ERC1155 multi-token design
Yul assembly math helpers
minimized storage writes
CREATE2 deterministic deployment
compact governance parameters
Yul Assembly Review

YulMath.sol was reviewed for:

overflow behavior
arithmetic correctness
unsafe memory writes

No critical issues identified.

Gas tests confirm reduced execution costs compared to standard Solidity implementations.

8. Access Control Review
Role Model
Role	Contract	Permission
RESOLVER_ROLE	PredictionMarket	Resolve markets
MINTER_ROLE	OutcomeToken	Mint shares
MINTER_ROLE	LPToken	Mint LP tokens
FEE_DEPOSITOR_ROLE	FeeVault	Deposit fees
UPGRADER_ROLE	Upgradeable Market	Upgrade implementation
Review Outcome

All privileged functions were confirmed protected.

No missing authorization checks were identified.

9. Centralization Risks

Current risks:

Risk	Description
Admin Roles	Initial deployment uses centralized admin
Oracle Dependency	Markets depend on oracle correctness
Governance Token Distribution	Voting power concentration possible

Mitigation plan:

Transfer admin privileges to governance after deployment.
10. Test Review
Test Types
Test Type	Status
Unit Tests	PASS
Fuzz Tests	PASS
Invariant Tests	PASS
Upgrade Tests	PASS
Governance Tests	PASS
Gas Tests	PASS
Coverage
Metric	Result
Line Coverage	91.98%
Statement Coverage	88.89%
Function Coverage	96.25%
11. Final Assessment

PredictX demonstrates:

strong modular architecture
strong test coverage
proper access-control separation
safe governance execution
validated oracle integration
correct CEI ordering
proper reentrancy protection
deterministic deployment safety
safe upgradeability practices

No High or Medium severity findings were identified during the review.

The protocol is suitable for educational deployment and further frontend/subgraph integration on Base Sepolia.

12. Appendix A — Slither Summary

Final Slither result:

0 High findings
0 Medium findings

Remaining informational findings:

timestamp usage
openzeppelin inherited event indexing notices

Reviewed and accepted.

13. Appendix B — Test Summary

Final automated testing result:

137 tests passing
0 failures

Invariant test result:

256 invariant runs
128,000 calls per invariant
0 invariant violations
14. Appendix C — Upgrade Validation

The following upgrade path was tested:

PredictionMarketUpgradeableV1
        ↓
PredictionMarketUpgradeableV2

Verified behaviors:

storage preservation
role preservation
version increment
unauthorized upgrade rejection

All upgrade tests passed successfully.