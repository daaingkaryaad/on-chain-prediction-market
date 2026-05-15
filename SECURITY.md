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
- Unit, fuzz, invariant, fork, gas, and upgradeability tests
- Base Sepolia deployment and contract verification

---

# Security Principles

## Checks-Effects-Interactions (CEI)

State mutations occur before external interactions where applicable to reduce reentrancy risk.

This pattern is used in core market flows such as:

- selling YES/NO shares
- removing liquidity
- claiming rewards

---

## Reentrancy Protection

Externally callable state-changing functions use `ReentrancyGuard` where applicable.

Protected flows include:

- `buyYes()`
- `buyNo()`
- `sellYes()`
- `sellNo()`
- `addLiquidity()`
- `removeLiquidity()`
- `claimRewards()`

---

## Role-Based Access Control

Administrative functionality is protected through OpenZeppelin `AccessControl`.

Critical roles include:

| Role | Purpose |
|---|---|
| `DEFAULT_ADMIN_ROLE` | Administrative control |
| `RESOLVER_ROLE` | Market resolution |
| `UPGRADER_ROLE` | UUPS upgrades |
| `MINTER_ROLE` | Controlled token minting |
| `FEE_DEPOSITOR_ROLE` | Fee vault deposits |
| `PROPOSER_ROLE` | Governance proposal queueing |
| `CANCELLER_ROLE` | Governance proposal cancellation |

---

## Timelock Governance

Governance execution is protected through a timelock delay.

| Parameter | Value |
|---|---|
| Voting Delay | 1 day |
| Voting Period | 1 week |
| Timelock Delay | 2 days |
| Proposal Threshold | 1% |
| Quorum | 4% |

The governance lifecycle is:

```text
propose → vote → queue → execute
```

Oracle Validation

Chainlink integrations validate:

stale oracle responses
incomplete rounds
invalid prices
zero timestamps
future timestamps

Oracle validation includes:

answeredInRound >= roundId
startedAt != 0
updatedAt != 0
updatedAt <= block.timestamp
price > 0
Slippage Protection

Trading operations enforce minimum output validation to reduce slippage risks during swaps.

Affected functions:

buyYes()
buyNo()
sellYes()
sellNo()
Upgrade Safety

Upgradeable contracts use the UUPS proxy pattern with restricted upgrade authorization.

Upgrade authorization is limited through:

UPGRADER_ROLE

The V1 → V2 upgrade path is tested, including unauthorized upgrade rejection.

Security Tooling
Static Analysis

The protocol was analyzed using Slither.

python3 -m slither . --config-file slither.config.json

Result summary:

Severity	Findings
High	0
Medium	0

Remaining informational findings are documented in the internal audit report.

Testing Strategy

The testing suite includes:

Unit tests
Fuzz tests
Invariant tests
Fork tests
Gas benchmarks
Upgradeability tests
Governance lifecycle tests
Deployment verification script
Coverage

Current test coverage:

Metric	Coverage
Line Coverage	91.98%
Statement Coverage	88.89%
Function Coverage	96.25%
Fork Testing

Fork tests validate interactions with real deployed protocols:

Test	External Protocol
ChainlinkFork.t.sol	Chainlink ETH/USD feed
USDCFork.t.sol	USDC
UniswapV2Fork.t.sol	Uniswap V2 Router
Deployment Security
Network
Item	Value
Network	Base Sepolia
Chain ID	84532
Deployment Status	Completed
Verification Status	Completed
Post-Deployment Verification

Deployment configuration is checked using:

forge script script/VerifyDeployment.s.sol:VerifyDeployment \
  --rpc-url base_sepolia

The script verifies:

Governor voting delay
Governor voting period
proposal threshold
Timelock delay
Governor proposer role
Governor canceller role
deployed role configuration

Expected output:

Deployment verification passed.
Known Risks
Oracle Dependency

Prediction resolution depends on external oracle availability and correctness.

Mitigations:

stale price validation
round completeness checks
invalid price rejection
configurable stale price delay
mock oracle only used for controlled testnet/demo flows
Governance Risk

Governance-controlled upgrades may introduce protocol risk.

Mitigations:

timelock execution delay
ERC20Votes governance
proposal threshold
quorum requirement
public proposal lifecycle
Timestamp Dependence

Certain protocol operations depend on block.timestamp.

Affected functionality:

market resolution windows
oracle freshness checks

This is intentional and acceptable for the protocol design. Timestamp is not used as a randomness source.

Centralized Initial Admin

Initial deployment uses a deployer-controlled admin account.

Mitigation plan:

transfer privileged roles to Timelock/governance
document role ownership
verify governance parameters after deployment
Audit Status
Review Type	Status
Internal Audit	Complete
Slither Analysis	Complete
Unit/Fuzz/Invariant Tests	Complete
Fork Tests	Complete
Deployment Verification	Complete
Formal External Audit	Pending

Internal audit report:

audits/security-audit.md
Reporting Vulnerabilities

If you discover a security vulnerability, report it responsibly.

Contact
Contact	Value
Team	Ingkar, Ansar, Kadirzhan
Network	Base Sepolia
Responsible Disclosure

Please avoid publicly disclosing vulnerabilities before remediation is available.

Include:

affected contracts
reproduction steps
severity assessment
expected impact
suggested mitigation, if available
Emergency Response

Potential emergency actions include:

governance proposals
timelock-controlled upgrades
market disabling
oracle replacement
frontend warnings
role revocation
Dependencies

The protocol relies on audited OpenZeppelin libraries including:

AccessControl
ERC20Votes
ERC20Permit
ERC4626
Governor
TimelockController
UUPSUpgradeable
SafeERC20
ReentrancyGuard
Final Notes

Security is an ongoing process.

PredictX prioritizes conservative smart contract design, extensive testing, governance-controlled upgrades, and clear deployment verification to minimize protocol risk.