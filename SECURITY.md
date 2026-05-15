# Security Policy

## PredictX Security Overview

PredictX is an on-chain prediction market protocol built with a security-first architecture.

The protocol includes:

- UUPS upgradeable contracts
- ERC20Votes governance
- Timelock-controlled administration
- CREATE2 deterministic deployments
- ERC4626 fee vaults
- Chainlink oracle integrations
- Invariant, fuzz, and unit testing suites

---

# Security Principles

The protocol follows several core security principles:

## Checks-Effects-Interactions (CEI)

State mutations occur before external interactions where applicable to reduce reentrancy risk.

---

## Role-Based Access Control

Administrative functionality is protected through OpenZeppelin `AccessControl`.

Critical roles include:

| Role | Purpose |
|---|---|
| DEFAULT_ADMIN_ROLE | Administrative control |
| RESOLVER_ROLE | Market resolution |
| UPGRADER_ROLE | UUPS upgrades |
| MINTER_ROLE | Controlled token minting |

---

## Timelock Governance

Governance execution is protected through a timelock delay.

Configuration:

| Parameter | Value |
|---|---|
| Voting Delay | 1 day |
| Voting Period | 1 week |
| Timelock Delay | 2 days |

---

## Oracle Validation

Chainlink integrations validate:

- stale oracle responses
- incomplete rounds
- invalid prices
- future timestamps

---

## Slippage Protection

Trading operations enforce minimum output validation to reduce slippage risks during swaps.

---

## Upgrade Safety

Upgradeable contracts use the UUPS proxy pattern with restricted upgrade authorization.

Upgrade authorization is limited to governance-controlled roles.

---

# Security Tooling

## Static Analysis

The protocol was analyzed using:

```bash
slither .

Result summary:

Severity	Findings
High	0
Medium	0
Testing Strategy

The testing suite includes:

Unit tests
Fuzz tests
Invariant tests
Gas benchmarks
Upgradeability tests
Coverage

Current test coverage:

Metric	Coverage
Line Coverage	> 90%
Function Coverage	> 95%
Known Risks
Oracle Dependency

Prediction resolution depends on external oracle availability and correctness.

Mitigation:

stale price validation
round completeness checks
configurable delays
Governance Risk

Governance-controlled upgrades may introduce protocol risk.

Mitigation:

timelock execution delay
ERC20Votes governance
proposal thresholds
quorum requirements
Timestamp Dependence

Certain protocol operations depend on block.timestamp.

Affected functionality:

market resolution windows
oracle freshness checks

This is intentional and acceptable for the protocol design.

Audit Status
Internal Review

The contracts underwent internal review and static analysis prior to deployment.

Audit status:

Review Type	Status
Internal Audit	Complete
Slither Analysis	Complete
Formal External Audit	Pending
Reporting Vulnerabilities

If you discover a security vulnerability, please report it responsibly.

Contact
Contact	Value
Team	Ingkar, Ansar, Kadirzhan
Network	Base Sepolia
Responsible Disclosure

Please avoid publicly disclosing vulnerabilities before remediation is available.

Provide:

affected contracts
reproduction steps
severity assessment
suggested mitigation if available
Emergency Response

Potential emergency actions include:

governance pause proposals
timelock-controlled upgrades
market disabling
oracle replacement
Dependencies

The protocol relies on audited OpenZeppelin libraries including:

AccessControl
ERC20Votes
ERC4626
Governor
TimelockController
UUPSUpgradeable