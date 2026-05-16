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
| Chain ID | `84532` |
| Deployment Status | Completed |
| Verification Status | Completed |
| Repository | Academic GitHub Repository |

---

## 1. Executive Summary

PredictX is a decentralized binary prediction market protocol deployed on Base Sepolia.

The protocol includes:

- CPMM-based AMM trading
- ERC-1155 outcome shares
- ERC-20 LP tokens
- ERC-4626 fee vault
- ERC20Votes governance
- Timelocked governance execution
- UUPS upgradeability
- Chainlink oracle validation
- Mock oracle support for testnet demonstrations
- CREATE and CREATE2 market deployment
- Base Sepolia deployment and verification

The review focused on:

- Reentrancy protection
- Checks-Effects-Interactions ordering
- Oracle validation
- Access control
- Governance execution
- Reserve accounting
- Upgradeability safety
- Liquidity accounting
- Reward claiming logic
- Deterministic deployment safety
- Deployment correctness

The protocol passed:

- Unit tests
- Fuzz tests
- Invariant tests
- Fork tests
- Upgrade tests
- Governance lifecycle tests
- Gas tests
- Post-deployment verification

Final testing metrics:

| Metric | Result |
|---|---:|
| Total Tests | 172 |
| Contract Line Coverage | 91.4% |
| Global Function Coverage | 92.22% |
| Slither High Findings | 0 |
| Slither Medium Findings | 0 |
| Invariant Failures | 0 |
| Post-Deployment Verification | Passed |

---

## 2. Deployment Summary

### Base Sepolia Deployment

| Contract | Address |
|---|---|
| `GovernanceToken` | `0x2F6E705b05BE552D64272B84E85806163B087d03` |
| `OutcomeToken` | `0xF1E2A7746B6F0909e761888b214433ec7A56C869` |
| `LPToken` | `0xf7203d68c9ec1d73e1d5c77c78182E31A48ABf3F` |
| `FeeVault` | `0x8E7e468e98a02e61eaD523709b82A86304A0E275` |
| `ProtocolTimelock` | `0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C` |
| `ProtocolGovernor` | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` |
| `PredictionMarketFactory` | `0xCF2A44203097275a975264a7C61798E12CE700aE` |
| `MockERC20` | `0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2` |
| `MockOracleAdapter` | `0x95E9428B717c80fb26588d65C64a4b37E299A8AC` |

Deployment registry:

```text
deployments/addresses.md
```

Post-deployment verification script:

```text
script/VerifyDeployment.s.sol
```

Verification result:

```text
Deployment verification passed.
Governor: 0x77b883238BAe5511935697B08080a4Dd90C9dCF8
Timelock: 0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
Factory: 0xCF2A44203097275a975264a7C61798E12CE700aE
FeeVault: 0x8E7e468e98a02e61eaD523709b82A86304A0E275
```

---

## 3. Scope

### 3.1 In-Scope Contracts

| Contract | Purpose |
|---|---|
| `PredictionMarket.sol` | Core AMM prediction market |
| `PredictionMarketFactory.sol` | Factory deployment with CREATE and CREATE2 |
| `PredictionMarketUpgradeable.sol` | UUPS upgradeable implementation |
| `PredictionMarketUpgradeableV2.sol` | Upgradeability test implementation |
| `ProtocolGovernor.sol` | Governance logic |
| `ProtocolTimelock.sol` | Timelock execution |
| `GovernanceToken.sol` | ERC20Votes governance token |
| `OutcomeToken.sol` | ERC1155 outcome shares |
| `LPToken.sol` | Liquidity provider token |
| `FeeVault.sol` | ERC4626 fee vault |
| `ChainlinkOracleAdapter.sol` | Chainlink oracle validation |
| `MockOracleAdapter.sol` | Testing and demo oracle |
| `MockChainlinkAggregator.sol` | Chainlink mock aggregator |
| `AMMMath.sol` | AMM pricing logic |
| `YulMath.sol` | Optimized assembly math |

### 3.2 Out-of-Scope

The following were not part of the smart contract audit scope:

- React frontend implementation
- The Graph hosted infrastructure
- RPC provider reliability
- Wallet provider behavior
- Base Sepolia network infrastructure
- Chainlink node infrastructure
- Centralized frontend hosting

---

## 4. Methodology

### 4.1 Manual Review

Manual review focused on:

- Privilege escalation
- Unsafe external calls
- Reserve accounting
- Upgradeability risks
- Access-control correctness
- CEI ordering
- Governance attack vectors
- Oracle validation
- Arithmetic safety
- Deterministic deployment
- Deployment configuration

### 4.2 Static Analysis

Tool used:

```text
Slither
```

Final Slither result:

```text
0 High findings
0 Medium findings
```

Remaining informational findings:

- Timestamp usage
- Inherited OpenZeppelin event indexing notices

These findings were reviewed manually and accepted.

### 4.3 Unit Testing

Implemented using:

```text
Foundry
```

Coverage areas:

- Market trading
- Liquidity management
- Reward claiming
- Governance lifecycle
- Upgrade authorization
- ERC4626 accounting
- Oracle validation
- Access-control enforcement
- Deployment verification

### 4.4 Fuzz Testing

Fuzz testing validated:

- AMM reserve transitions
- Slippage bounds
- Buy/sell consistency
- Liquidity operations
- Invalid slippage reverts

### 4.5 Invariant Testing

Invariant testing validated:

- Reserves never become zero
- LP supply accounting
- Collateral accounting consistency
- Market state consistency
- Outcome supply bounds

Invariant result:

```text
256 runs
128,000 calls per invariant
0 invariant violations
```

### 4.6 Fork Testing

Fork tests interact with real Ethereum mainnet protocols.

Fork targets:

| Protocol | Purpose |
|---|---|
| Chainlink ETH/USD Feed | Validate live feed reads |
| USDC | Validate real ERC20 metadata and transfers |
| Uniswap V2 Router | Validate real router pair and quote behavior |

Fork tests provide confidence that integration logic works against real deployed protocols rather than only mocks.

---

## 5. System Architecture Security Review

### 5.1 PredictionMarket.sol

#### Overview

`PredictionMarket.sol` is the core market contract responsible for:

- Buying YES shares
- Buying NO shares
- Selling YES shares
- Selling NO shares
- Adding liquidity
- Removing liquidity
- Resolving markets
- Claiming rewards

#### Security Properties

| Property | Status |
|---|---|
| Reentrancy Protection | PASS |
| Slippage Protection | PASS |
| CEI Ordering | PASS |
| Access Control | PASS |
| Reserve Validation | PASS |
| SafeERC20 Usage | PASS |

#### Reentrancy Protection

All relevant external state-changing functions use:

```solidity
nonReentrant
```

Protected functions:

- `buyYes()`
- `buyNo()`
- `sellYes()`
- `sellNo()`
- `addLiquidity()`
- `removeLiquidity()`
- `claimRewards()`

#### CEI Ordering

State updates occur before external token transfers where applicable.

Example:

```solidity
claimed[msg.sender] = true;
outcomeToken.burn(...);
collateralToken.safeTransfer(...);
```

For sell and liquidity removal operations, reserve updates are applied before token burn and collateral transfer operations.

This reduces reentrancy risk and makes state transitions easier to audit.

#### Slippage Protection

Trading operations enforce user-defined minimum outputs:

```solidity
AMMMath.validateSlippage(...);
```

This protects users against:

- Reserve front-running
- Unexpected price impact
- MEV-related execution changes
- Adverse AMM movement

#### Reserve Safety

The protocol prevents invalid reserve depletion:

```solidity
if (sharesOut >= reserve) revert InsufficientLiquidity();
```

and:

```solidity
if (collateralOut >= reserve) revert InsufficientLiquidity();
```

These checks prevent impossible AMM states.

### 5.2 PredictionMarketFactory.sol

#### CREATE and CREATE2 Review

The factory supports:

- CREATE
- CREATE2

CREATE2 deterministic deployment was reviewed for:

- Salt collision safety
- Deterministic address correctness
- Deployment uniqueness
- Predictable market address behavior

No collision vulnerabilities were identified.

#### Input Validation

Factory deployment validates:

- Zero addresses
- Initial liquidity
- Creator permissions

Unauthorized deployment is prevented through:

```solidity
CREATOR_ROLE
```

### 5.3 Upgradeability Review

#### UUPS Proxy Security

The upgradeable implementation uses:

```solidity
UUPSUpgradeable
```

Upgrade authorization:

```solidity
onlyRole(UPGRADER_ROLE)
```

#### Risks Reviewed

| Risk | Result |
|---|---|
| Unauthorized Upgrade | PASS |
| Reinitialization | PASS |
| Storage Collision | PASS |
| Broken Upgrade Path | PASS |

#### Reinitialization Protection

The initializer uses:

```solidity
initializer
```

Repeated initialization reverts correctly.

#### Upgrade Authorization

Only accounts with:

```solidity
UPGRADER_ROLE
```

may upgrade implementations.

Unauthorized upgrades revert correctly.

### 5.4 Governance Review

#### Governance Components

| Component | Purpose |
|---|---|
| `GovernanceToken` | Voting power |
| `ProtocolGovernor` | Proposal lifecycle |
| `ProtocolTimelock` | Delayed execution |

#### Governance Security

The governance lifecycle was fully tested:

```text
propose → vote → queue → execute
```

Governance protections:

| Mechanism | Purpose |
|---|---|
| Voting Delay | Prevent immediate proposal activation |
| Voting Period | Allow participation |
| Proposal Threshold | Prevent proposal spam |
| Quorum | Require meaningful participation |
| Timelock Delay | Delay execution |

#### Governance Attack Review

##### Flash Loan Governance Attack

Mitigation:

```text
ERC20Votes snapshot checkpointing
```

Voting power is measured historically. This prevents same-block borrowing from immediately controlling governance voting weight.

##### Instant Malicious Execution

Mitigation:

```text
2-day timelock delay
```

Users and maintainers have time to react before successful proposals execute.

##### Proposal Spam

Mitigation:

```text
1% proposal threshold
```

Only token holders with sufficient voting power can create proposals.

##### Whale Attack

Risk:

A large token holder can influence governance outcomes.

Mitigation:

- Quorum requirement
- Voting period
- Public proposal lifecycle
- Timelock delay

Residual risk remains if governance token supply becomes highly concentrated.

### 5.5 Oracle Security Review

#### Oracle Validation

The Chainlink adapter validates:

```solidity
answeredInRound >= roundId
startedAt != 0
updatedAt != 0
updatedAt <= block.timestamp
price > 0
block.timestamp - updatedAt <= stalePriceDelay
```

#### Oracle Risks Reviewed

| Risk | Result |
|---|---|
| Stale Data | PASS |
| Incomplete Round | PASS |
| Negative Price | PASS |
| Future Timestamp | PASS |
| Invalid Feed Address | PASS |

#### Timestamp Dependence

Slither flagged timestamp usage.

Reviewed timestamp usage:

```solidity
block.timestamp < resolutionTime
block.timestamp - updatedAt > stalePriceDelay
```

Assessment:

```text
Accepted
```

Reason:

- Timestamp checks are necessary for market deadlines
- Oracle freshness inherently requires time-based validation
- Timestamp is not used as randomness
- Validator timestamp manipulation range is too small to materially impact the protocol

Severity:

```text
Informational
```

### 5.6 ERC4626 Vault Review

#### FeeVault.sol

The vault implements standardized ERC4626 accounting.

Reviewed properties:

| Property | Status |
|---|---|
| Share Accounting | PASS |
| Deposit Validation | PASS |
| Withdraw Accounting | PASS |
| Access Control | PASS |

#### ERC4626 Rounding Review

ERC4626 behavior was tested through deposit and withdraw flows.

Reviewed areas:

- Share minting
- Asset accounting
- Withdrawal behavior
- Total managed assets

No rounding issue causing asset loss was identified in tested flows.

### 5.7 Yul Assembly Review

`YulMath.sol` includes isolated assembly helpers.

Reviewed functions:

- `min()`
- `max()`
- `mulDiv()`

Reviewed risks:

- Unsafe memory writes
- Unexpected overflow behavior
- Division by zero
- Incorrect return values

`mulDiv()` includes denominator validation.

No critical issue was identified.

---

## 6. Reproduced and Fixed Vulnerability Case Studies

### 6.1 Case Study 1 — Reentrancy Pattern in Market Exit Functions

#### Severity

Medium before mitigation.

#### Location

```text
src/core/PredictionMarket.sol
```

Affected functions:

- `sellYes()`
- `sellNo()`
- `removeLiquidity()`

#### Description

Static analysis detected a reentrancy-pattern warning because some state updates previously occurred after external token calls.

Although the functions were protected with `nonReentrant`, the original ordering created an avoidable CEI weakness.

#### Impact

A malicious token implementation or unexpected external call behavior could attempt nested execution before reserves were fully updated.

#### Proof of Concept

The issue was reproduced through Slither static analysis.

Finding category:

```text
reentrancy-no-eth
```

#### Recommendation

Apply Checks-Effects-Interactions ordering.

#### Fix

Reserve updates were moved before token burn and collateral transfer operations.

#### Status

Fixed.

### 6.2 Case Study 2 — Access-Control Protection for Privileged Functions

#### Severity

High if missing, prevented by design.

#### Location

```text
src/tokens/OutcomeToken.sol
src/tokens/LPToken.sol
src/vault/FeeVault.sol
src/core/PredictionMarket.sol
src/core/PredictionMarketUpgradeable.sol
```

#### Description

Privileged functions must not be externally callable by unauthorized users.

Reviewed privileged functionality:

- Minting outcome shares
- Minting LP tokens
- Depositing protocol fees
- Resolving markets
- Upgrading implementations

#### Impact

If access control were missing, attackers could mint tokens, manipulate outcomes, upgrade logic, or alter fee accounting.

#### Proof of Concept

Before/after behavior is covered through revert-path tests:

- Non-minter cannot mint outcome tokens
- Non-minter cannot mint LP tokens
- Non-role caller cannot deposit protocol fees
- Non-resolver cannot resolve market
- Non-upgrader cannot upgrade implementation
- Non-admin cannot set mock oracle resolution

#### Recommendation

Use OpenZeppelin `AccessControl` and role-gated privileged functions.

#### Fix

Privileged functions are restricted using role checks.

#### Status

Fixed / Prevented by Design.

---

## 7. Findings Summary

### 7.1 Final Findings Table

| Severity | Count |
|---|---:|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| Informational | 2 |
| Gas | 0 |

---

## 8. Informational Findings

### INFO-01: Timestamp Dependence

#### Severity

Informational.

#### Location

```text
src/core/PredictionMarket.sol
src/oracle/ChainlinkOracleAdapter.sol
src/oracle/MockOracleAdapter.sol
```

#### Description

Several contracts use:

```solidity
block.timestamp
```

for:

- Market resolution deadlines
- Oracle freshness validation

#### Impact

Validators can slightly manipulate timestamps.

#### Assessment

Accepted.

The manipulation range is insufficient to materially impact protocol behavior. Timestamp is not used for randomness.

#### Recommendation

Document timestamp usage and avoid using it for randomness.

#### Status

Acknowledged.

### INFO-02: OpenZeppelin Event Indexing Notices

#### Severity

Informational.

#### Location

```text
OpenZeppelin Governor / Timelock / ERC1967 dependencies
```

#### Description

Slither flagged inherited OpenZeppelin events with non-indexed address parameters.

#### Impact

No direct security impact in project-owned contracts.

#### Assessment

Accepted as dependency-level informational output.

#### Recommendation

No action required.

#### Status

Accepted.

---

## 9. Gas and Bytecode Review

### Contract Size Validation

All contracts remain below:

```text
EIP-170 runtime size limit: 24,576 bytes
```

Largest contract:

```text
ProtocolGovernor.sol
15,535 bytes runtime
```

Remaining margin:

```text
9,041 bytes
```

### Gas Optimization Review

Optimizations identified:

- Immutable variables
- Custom errors
- ERC1155 multi-token design
- Yul assembly math helpers
- Minimized storage writes
- CREATE2 deterministic deployment
- Compact governance parameters
- SafeERC20 usage
- CEI ordering

### Yul Assembly Review

`YulMath.sol` was reviewed for:

- Overflow behavior
- Arithmetic correctness
- Unsafe memory writes

No critical issues were identified.

---

## 10. Access Control Review

### Role Model

| Role | Contract | Permission |
|---|---|---|
| `RESOLVER_ROLE` | `PredictionMarket` | Resolve markets |
| `MINTER_ROLE` | `OutcomeToken` | Mint shares |
| `MINTER_ROLE` | `LPToken` | Mint LP tokens |
| `FEE_DEPOSITOR_ROLE` | `FeeVault` | Deposit fees |
| `UPGRADER_ROLE` | Upgradeable Market | Upgrade implementation |
| `PROPOSER_ROLE` | `ProtocolTimelock` | Queue governance proposals |
| `CANCELLER_ROLE` | `ProtocolTimelock` | Cancel queued proposals |

### Review Outcome

All privileged functions were confirmed protected.

No missing authorization checks were identified in project-owned contracts.

---

## 11. Centralization Risks

Current risks:

| Risk | Description | Mitigation |
|---|---|---|
| Admin Roles | Initial deployment uses deployer-controlled roles | Transfer admin powers to Timelock |
| Oracle Dependency | Markets depend on oracle correctness | Use Chainlink validation and stale checks |
| Governance Token Distribution | Voting power concentration possible | Quorum, proposal threshold, public voting |
| Upgrade Authority | Upgrade role can change implementation | Restrict upgrades through governance |

---

## 12. Governance Attack Analysis

### Flash Loan Governance Attack

Mitigation:

- ERC20Votes checkpointing
- Voting delay
- Proposal threshold

Residual risk:

- Governance token concentration remains a social/economic risk.

### Whale Attack

Mitigation:

- Quorum requirement
- Timelock delay
- Transparent proposal lifecycle

Residual risk:

- A whale with enough voting power can influence governance.

### Proposal Spam

Mitigation:

- 1% proposal threshold

### Timelock Bypass

Mitigation:

- Governor must queue through Timelock
- Post-deployment verification checks proposer and canceller roles
- 2-day minimum delay

---

## 13. Oracle Attack Analysis

### Price Manipulation

Risk:

Oracle feed data may be manipulated if the external feed fails or is misconfigured.

Mitigation:

- Use Chainlink data feeds
- Reject invalid price values
- Reject incomplete rounds

### Stale Price

Risk:

Old data could resolve markets incorrectly.

Mitigation:

```solidity
block.timestamp - updatedAt <= stalePriceDelay
```

### Feed Depeg / Incorrect Feed

Risk:

Wrong feed address or depegged underlying asset can produce incorrect outcomes.

Mitigation:

- Deployment verification
- Feed documentation
- Explicit environment configuration

---

## 14. Test Review

### Test Types

| Test Type | Status |
|---|---|
| Unit Tests | PASS |
| Fuzz Tests | PASS |
| Invariant Tests | PASS |
| Fork Tests | PASS |
| Upgrade Tests | PASS |
| Governance Tests | PASS |
| Gas Tests | PASS |
| Deployment Verification | PASS |

### Coverage

| Metric | Result |
|---|---:|
| Line Coverage | 91.98% |
| Statement Coverage | 88.89% |
| Function Coverage | 96.25% |

---

## 15. Final Assessment

PredictX demonstrates:

- Modular protocol architecture
- Strong test coverage
- Proper access-control separation
- Safe governance execution
- Validated oracle integration
- Correct CEI ordering
- Proper reentrancy protection
- Deterministic deployment support
- Safe upgradeability practices
- Verified Base Sepolia deployment
- Post-deployment configuration validation

No High or Medium severity findings were identified during the review.

The protocol is suitable for educational deployment and further frontend/subgraph integration on Base Sepolia.

---

## 16. Appendix A — Slither Summary

Final Slither result:

```text
0 High findings
0 Medium findings
```

Remaining informational findings:

- Timestamp usage
- OpenZeppelin inherited event indexing notices

Reviewed and accepted.

---

## 17. Appendix B — Test Summary

Final automated testing result:

```text
137+ tests passing
0 failures
```

Invariant test result:

```text
256 invariant runs
128,000 calls per invariant
0 invariant violations
```

Coverage result:

```text
Line Coverage: 91.98%
Statement Coverage: 88.89%
Function Coverage: 96.25%
```

---

## 18. Appendix C — Fork Test Summary

Fork tests validate integration with real deployed protocols:

| Fork Test | External Protocol |
|---|---|
| `ChainlinkFork.t.sol` | Chainlink ETH/USD Feed |
| `USDCFork.t.sol` | USDC |
| `UniswapV2Fork.t.sol` | Uniswap V2 Router |

---

## 19. Appendix D — Upgrade Validation

The following upgrade path was tested:

```text
PredictionMarketUpgradeableV1
        ↓
PredictionMarketUpgradeableV2
```

Verified behaviors:

- Storage preservation
- Role preservation
- Version increment
- Unauthorized upgrade rejection

All upgrade tests passed successfully.

---

## 20. Appendix E — Deployment Verification

Deployment verification script:

```text
script/VerifyDeployment.s.sol
```

Verified:

- Governor voting delay
- Governor voting period
- Proposal threshold
- Timelock delay
- Governor proposer role
- Governor canceller role
- Deployed contract role configuration

Output:

```text
Deployment verification passed.
Governor: 0x77b883238BAe5511935697B08080a4Dd90C9dCF8
Timelock: 0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
Factory: 0xCF2A44203097275a975264a7C61798E12CE700aE
FeeVault: 0x8E7e468e98a02e61eaD523709b82A86304A0E275
```