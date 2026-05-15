# PredictX Architecture & Design Document

## 1. System Overview

PredictX is an on-chain binary prediction market protocol deployed on Base Sepolia. The protocol allows users to create, trade, and resolve binary outcome markets using YES and NO outcome shares.

Each market follows a lifecycle:

```text
Created → Open → Resolved → Claimed
```

Users interact with the system through a React frontend. Market and trading events are indexed through The Graph subgraph for efficient querying and analytics.

The protocol combines:

- CPMM-based AMM pricing
- ERC-1155 outcome tokens
- ERC-20 LP tokens
- ERC-4626 fee vault
- ERC20Votes governance
- Governor + Timelock execution
- Chainlink oracle validation
- UUPS upgradeability
- Factory deployment through CREATE and CREATE2
- Base Sepolia L2 deployment and verification

---

## 2. Business Logic

Prediction markets allow users to speculate on future binary outcomes.

Example market:

```text
Will ETH trade above $5,000 by December 31, 2026?
```

Users can:

- Buy YES shares
- Buy NO shares
- Sell shares before market resolution
- Provide liquidity
- Remove liquidity
- Claim rewards after resolution
- Vote on protocol-level governance proposals

The market price is determined by a Constant Product Market Maker.

```text
x * y = k
```

Where:

- `x` = YES reserve
- `y` = NO reserve
- `k` = constant product invariant

When users buy YES shares, YES-side demand increases and reserve balances shift. The same pricing mechanism applies to NO shares.

---

## 3. System Context Diagram

```text
+------------------+
|      User        |
+--------+---------+
         |
         v
+------------------+
|  React Frontend  |
+--------+---------+
         |
         v
+-----------------------------+
|       Smart Contracts       |
|-----------------------------|
| PredictionMarket            |
| PredictionMarketFactory     |
| OutcomeToken                |
| LPToken                     |
| FeeVault                    |
| GovernanceToken             |
| ProtocolGovernor            |
| ProtocolTimelock            |
| ChainlinkOracleAdapter      |
| MockOracleAdapter           |
+-------------+---------------+
              |
              v
+-----------------------------+
|       Base Sepolia L2       |
+-----------------------------+

External services:

+------------------+        +------------------+
| Chainlink Feeds  |        |   The Graph      |
+------------------+        +------------------+
```

![alt text](image-1.png)

---

## 4. Container / Component Diagram

```text
PredictionMarketFactory
        |
        | CREATE / CREATE2
        v
PredictionMarket
        |
        | mints / burns outcome shares
        v
OutcomeToken ERC1155

PredictionMarket
        |
        | mints / burns LP shares
        v
LPToken ERC20

PredictionMarket
        |
        | reads resolution data
        v
MockOracleAdapter / ChainlinkOracleAdapter

GovernanceToken ERC20Votes
        |
        | voting power
        v
ProtocolGovernor
        |
        | queued successful proposals
        v
ProtocolTimelock
        |
        | delayed execution
        v
Protocol-controlled actions

FeeVault ERC4626
        |
        | protocol fee accounting
        v
Collateral Token
```

![alt text](image-1.png)

---

## 5. Deployed Base Sepolia Contracts

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

The verification script confirms:

- Governor voting delay
- Governor voting period
- Proposal threshold
- Timelock delay
- Governor proposer role
- Governor canceller role
- Deployed contract role configuration

---

## 6. Smart Contract Overview

### 6.1 PredictionMarket.sol

`PredictionMarket.sol` is the main market contract.

Responsibilities:

- Stores market metadata
- Manages YES and NO reserves
- Executes buy and sell operations
- Handles liquidity provision and removal
- Resolves the market through oracle data
- Allows winners to claim payouts

Main functions:

- `buyYes()`
- `buyNo()`
- `sellYes()`
- `sellNo()`
- `addLiquidity()`
- `removeLiquidity()`
- `resolveMarket()`
- `claimRewards()`
- `getMarketReserves()`

Security features:

- `nonReentrant`
- CEI ordering
- Slippage protection
- Access-controlled resolution
- SafeERC20 transfers
- Reserve depletion checks

### 6.2 PredictionMarketFactory.sol

The factory deploys new prediction markets.

It supports both:

- CREATE
- CREATE2

CREATE is used for standard market deployment. CREATE2 is used for deterministic deployment where a future market address can be predicted before deployment.

Responsibilities:

- Validate deployment inputs
- Deploy markets
- Track deployed market addresses
- Emit market creation events
- Support deterministic address generation

Design pattern:

```text
Factory Pattern
```

### 6.3 PredictionMarketUpgradeable.sol

The protocol includes a UUPS-upgradeable market implementation to demonstrate a safe V1 → V2 upgrade path.

Implemented features:

- `Initializable`
- `UUPSUpgradeable`
- `AccessControlUpgradeable`
- `ReentrancyGuardUpgradeable`
- Upgrade authorization through `UPGRADER_ROLE`

The V2 mock implementation adds:

- `newFunction()`
- `version()` returns `2`

This demonstrates a controlled upgrade path without forcing the production market implementation to depend on proxy storage.

### 6.4 OutcomeToken.sol

`OutcomeToken.sol` is an ERC-1155 token contract.

Each market has two outcome token IDs:

- YES token
- NO token

Token IDs are generated from:

```solidity
keccak256(abi.encodePacked(marketId, outcome))
```

Responsibilities:

- Mint YES/NO shares
- Burn YES/NO shares
- Track outcome token supply
- Restrict minting through `MINTER_ROLE`

### 6.5 LPToken.sol

`LPToken.sol` is an ERC-20 liquidity provider token.

Responsibilities:

- Mint LP shares when liquidity is added
- Burn LP shares when liquidity is removed
- Restrict minting and burning through `MINTER_ROLE`

### 6.6 FeeVault.sol

`FeeVault.sol` implements ERC-4626 tokenized vault logic.

Responsibilities:

- Accept protocol fee deposits
- Issue vault shares
- Track total managed assets
- Support standardized deposit and withdraw behavior
- Provide vault accounting for protocol-controlled assets

Design pattern:

```text
Tokenized Vault
```

### 6.7 GovernanceToken.sol

`GovernanceToken.sol` is the protocol governance token.

It implements:

- ERC-20
- ERC20Permit
- ERC20Votes

Responsibilities:

- Provide voting power
- Support delegation
- Support permit-based approvals
- Enforce maximum supply

### 6.8 ProtocolGovernor.sol

`ProtocolGovernor.sol` implements OpenZeppelin Governor-based DAO governance.

Governance parameters:

| Parameter | Value |
|---|---|
| Voting Delay | 1 day |
| Voting Period | 1 week |
| Quorum | 4% |
| Proposal Threshold | 1% |

The full governance lifecycle is tested:

```text
propose → vote → queue → execute
```

### 6.9 ProtocolTimelock.sol

`ProtocolTimelock.sol` delays execution of successful governance proposals.

Timelock delay:

```text
2 days
```

The timelock protects the protocol against immediate malicious governance execution and gives users time to react.

### 6.10 ChainlinkOracleAdapter.sol

`ChainlinkOracleAdapter.sol` reads Chainlink price feeds.

Validation checks:

```solidity
answeredInRound >= roundId
startedAt != 0
updatedAt != 0
updatedAt <= block.timestamp
price > 0
block.timestamp - updatedAt <= stalePriceDelay
```

This protects the protocol from:

- Stale oracle data
- Incomplete Chainlink rounds
- Invalid negative or zero prices
- Future timestamp data

### 6.11 MockOracleAdapter.sol

`MockOracleAdapter.sol` is used for local testing and Base Sepolia demo flows.

Responsibilities:

- Set deterministic market resolutions
- Clear resolutions
- Configure max staleness
- Support resolution freshness checks
- Simulate oracle behavior for tests and demos

---

## 7. Sequence Diagram: Buy YES Shares

```text
User
 |
 | approve collateral
 v
Collateral Token
 |
 | buyYes(collateralAmount, minSharesOut)
 v
PredictionMarket
 |
 | validates market state
 | transfers collateral
 | calculates AMM output
 | checks slippage
 | updates reserves
 | mints YES ERC1155 shares
 v
OutcomeToken
```
![alt text](image.png)

Security properties:

- Rejects zero input
- Checks slippage
- Prevents reserve depletion
- Uses SafeERC20
- Applies ReentrancyGuard

---

## 8. Sequence Diagram: Sell YES Shares

```text
User
 |
 | sellYes(shareAmount, minCollateralOut)
 v
PredictionMarket
 |
 | validates market state
 | calculates collateral output
 | checks slippage
 | updates reserves
 | burns YES shares
 | transfers collateral
 v
User
```

![alt text](image.png)

Security properties:

- Checks market state
- Checks minimum output
- Updates reserves before external interactions
- Burns outcome tokens
- Safely transfers collateral

---

## 9. Sequence Diagram: Governance Execution

```text
Token Holder
 |
 | delegate voting power
 v
GovernanceToken
 |
 | propose()
 v
ProtocolGovernor
 |
 | voting delay
 | voting period
 | castVote()
 | queue()
 v
ProtocolTimelock
 |
 | 2 day delay
 | execute()
 v
Target Contract
```

![alt text](image.png)

Security properties:

- ERC20Votes checkpointing
- Proposal threshold
- Quorum threshold
- Timelock execution delay
- Full lifecycle testing

---

## 10. Sequence Diagram: Market Resolution

```text
Resolver
 |
 | resolveMarket()
 v
PredictionMarket
 |
 | checks resolutionTime
 | reads oracle resolution
 | validates oracle freshness
 | sets winning outcome
 | changes state to Resolved
 v
Users claim rewards
```

![alt text](image.png)

Security properties:

- Role-gated resolution
- Timestamp deadline check
- Oracle freshness validation
- One-way state transition to resolved

---

## 11.1 Sequence Diagram: ERC4626 Vault Deposit

![alt text](image.png)

Security properties:

- Uses ERC4626 standardized deposit accounting
- Requires prior ERC20 approval
- Mints vault shares to the receiver
- Tracks total managed assets
- Uses OpenZeppelin vault mechanics

---

## 11.1 Access Control Model

| Contract | Role | Permission |
|---|---|---|
| `PredictionMarket` | `RESOLVER_ROLE` | Resolve market |
| `OutcomeToken` | `MINTER_ROLE` | Mint outcome shares |
| `LPToken` | `MINTER_ROLE` | Mint/burn LP tokens |
| `FeeVault` | `FEE_DEPOSITOR_ROLE` | Deposit protocol fees |
| `PredictionMarketUpgradeable` | `UPGRADER_ROLE` | Upgrade implementation |
| `ProtocolTimelock` | `PROPOSER_ROLE` | Queue proposals |
| `ProtocolTimelock` | `CANCELLER_ROLE` | Cancel proposals |

No privileged function is intentionally left unguarded.


---

## 12. Design Patterns

### 12.1 Factory Pattern

Used in:

```text
PredictionMarketFactory.sol
```

Purpose:

- Deploy markets consistently
- Track all created markets
- Support CREATE and CREATE2 deployment

### 12.2 UUPS Proxy Pattern

Used in:

```text
PredictionMarketUpgradeable.sol
```

Purpose:

- Demonstrate upgradeable architecture
- Restrict upgrades through `UPGRADER_ROLE`
- Support V1 → V2 upgrade path

### 12.3 Checks-Effects-Interactions

Used in:

```text
PredictionMarket.sol
```

Purpose:

- Update state before external calls
- Reduce reentrancy risk
- Improve auditability

### 12.4 Reentrancy Guard

Used in:

```text
PredictionMarket.sol
PredictionMarketUpgradeable.sol
```

Purpose:

- Prevent nested external calls
- Protect trading, liquidity, and claiming flows

### 12.5 Access Control

Used in:

```text
OutcomeToken.sol
LPToken.sol
FeeVault.sol
PredictionMarket.sol
PredictionMarketUpgradeable.sol
```

Purpose:

- Restrict privileged operations
- Separate admin, minter, resolver, depositor, and upgrader permissions

### 12.6 Oracle Adapter Pattern

Used in:

```text
ChainlinkOracleAdapter.sol
MockOracleAdapter.sol
```

Purpose:

- Abstract oracle logic
- Support mocks in testing
- Support Chainlink integration in deployment

### 12.7 Timelock Pattern

Used in:

```text
ProtocolTimelock.sol
```

Purpose:

- Delay governance execution
- Reduce governance attack impact
- Give users time to react

### 12.8 State Machine

Used in:

```text
PredictionMarket.sol
```

Market states:

- Open
- Locked
- Resolved
- Disputed
- Cancelled

The current implementation primarily uses:

```text
Open → Resolved
```

Additional states are included for extensibility.

---

## 13. Storage Layout

### 13.1 PredictionMarket.sol

| Variable | Type | Description |
|---|---|---|
| `collateralToken` | `IERC20 immutable` | Collateral token |
| `outcomeToken` | `OutcomeToken immutable` | ERC1155 outcome token |
| `lpToken` | `LPToken immutable` | LP token |
| `oracleAdapter` | `IOracleAdapter immutable` | Oracle adapter |
| `marketId` | `bytes32 immutable` | Unique market ID |
| `question` | `string` | Market question |
| `resolutionTime` | `uint256 immutable` | Resolution timestamp |
| `yesReserve` | `uint256` | YES reserve |
| `noReserve` | `uint256` | NO reserve |
| `claimed` | `mapping(address => bool)` | Claim status |
| `marketState` | `MarketState` | Current lifecycle state |
| `winningOutcome` | `Outcome` | Winning result |

### 13.2 PredictionMarketUpgradeable.sol

| Variable | Type | Description |
|---|---|---|
| `marketQuestion` | `string` | Market question |
| `collateralToken` | `address` | Collateral token address |
| `versionNumber` | `uint256` | Version marker |

Upgradeable storage is intentionally minimal to reduce storage collision risk.

The upgrade path is validated through:

```text
PredictionMarketUpgradeable V1 → PredictionMarketUpgradeableV2
```

### 13.3 GovernanceToken.sol

| Variable / Feature | Description |
|---|---|
| ERC20 storage | Token balances and allowances |
| ERC20Votes checkpoints | Historical voting power |
| ERC20Permit nonces | Permit authorization |
| Max supply | Supply cap enforcement |

### 13.4 FeeVault.sol

| Variable / Feature | Description |
|---|---|
| ERC4626 asset | Underlying vault asset |
| ERC20 shares | Vault share accounting |
| AccessControl roles | Fee depositor authorization |
| `totalAssets` | Managed asset accounting |

---

## 14. Trust Assumptions

The protocol assumes:

- Chainlink feeds provide correct market data
- Mock oracle data is acceptable only for testnet/demo deployment
- Timelock governance is not controlled by a malicious voting majority
- Admin roles are transferred to governance before production use
- ERC20 collateral tokens behave according to the ERC20 standard
- Users understand slippage parameters before submitting transactions
- Market resolution timestamps are acceptable for deadline checks

---

## 15. Security Assumptions

### 15.1 Oracle Security

Oracle data is rejected if:

- Price is zero or negative
- Update timestamp is zero
- Update timestamp is in the future
- Data is older than `stalePriceDelay`
- Chainlink round is incomplete

### 15.2 Governance Security

Governance is protected by:

- ERC20Votes checkpointing
- Quorum requirement
- Proposal threshold
- Voting delay
- Voting period
- Timelock delay

### 15.3 AMM Security

Trading is protected by:

- Slippage protection
- Reserve checks
- Non-zero amount checks
- SafeERC20 transfers
- ReentrancyGuard
- CEI ordering

---

## 16. Testing Architecture

The test suite includes:

| Test Type | Status |
|---|---|
| Unit Tests | Passing |
| Fuzz Tests | Passing |
| Invariant Tests | Passing |
| Fork Tests | Passing |
| Gas Tests | Passing |
| Upgrade Tests | Passing |
| Governance Lifecycle Tests | Passing |

Current test count:

```text
163 tests passing
```

Coverage:

```text
Contract Line Coverage: 90.54%
Global Function Coverage: 92.22%
Total Tests: 163 passing
```

Fork tests interact with real mainnet protocols:

- Chainlink ETH/USD feed
- USDC token
- Uniswap V2 Router

---

## 17. CI/CD Architecture

GitHub Actions runs on:

- `push`
- `pull_request`

Pipeline checks:

```bash
forge fmt --check
forge build --sizes
forge test
forge coverage
forge snapshot
slither . --config-file slither.config.json
```

The pipeline prevents merging when formatting, tests, coverage, build, or security checks fail.

---

## 18. Deployment Architecture

Target network:

```text
Base Sepolia
```

Deployment scripts:

- `script/DeployMocks.s.sol`
- `script/Deploy.s.sol`
- `script/VerifyDeployment.s.sol`

Deployment stages:

1. Deploy mock collateral and mock oracle.
2. Deploy protocol contracts.
3. Verify contracts on BaseScan.
4. Run post-deployment verification script.
5. Record addresses in `deployments/addresses.md`.

Post-deployment verification confirms:

- Governor configuration
- Timelock delay
- Role assignment
- Deployed contract addresses
- Deployment consistency

---

## 19. Architecture Decision Records

### ADR-001: CPMM Instead of LMSR

Context:

Prediction markets can use LMSR or CPMM pricing.

Decision:

The protocol uses CPMM.

Reason:

- Simpler to implement and audit
- Easier to test with invariants
- Better fit for course requirements
- Clear `x * y = k` mathematical model

Consequences:

- Pricing is reserve-sensitive
- Liquidity depth strongly affects slippage
- LP management becomes important

### ADR-002: ERC1155 for Outcome Shares

Context:

Each market requires YES and NO shares.

Decision:

Use ERC1155.

Reason:

- Efficient multi-token standard
- Natural fit for multiple markets
- Lower deployment overhead than separate ERC20 tokens per market

Consequences:

- Token IDs must be derived safely
- Frontend must decode market/outcome IDs

### ADR-003: Governor + Timelock

Context:

Protocol parameters and privileged actions require governance.

Decision:

Use OpenZeppelin Governor with TimelockController.

Reason:

- Battle-tested implementation
- Required by project specification
- Clear proposal lifecycle

Consequences:

- Governance flow is more complex
- Testing requires block rolling and timestamp manipulation

### ADR-004: UUPS Upgradeability

Context:

Project requires an upgradeable contract with V1 → V2 path.

Decision:

Use UUPS upgradeability.

Reason:

- Lower proxy overhead than Transparent Proxy
- Explicit upgrade authorization
- OpenZeppelin-supported pattern

Consequences:

- Storage layout must be documented
- Initializers must replace constructors
- Upgrade permissions must be tightly controlled

### ADR-005: Chainlink Oracle Adapter

Context:

Markets require external data to resolve outcomes.

Decision:

Use a Chainlink adapter contract.

Reason:

- Separates oracle logic from market logic
- Supports mocking in tests
- Allows future replacement of oracle implementation

Consequences:

- Adapter must validate stale data
- Adapter must reject incomplete rounds
- Timestamp checks must be documented in audit

### ADR-006: Base Sepolia Deployment

Context:

The project requires deployment and verification on an L2 testnet.

Decision:

Deploy to Base Sepolia.

Reason:

- EVM-compatible
- Supported by Foundry
- Low deployment cost
- Block explorer verification available through BaseScan

Consequences:

- Frontend must detect Base Sepolia
- Deployment documentation must include chain ID `84532`
- Gas comparison against L1 must be documented

---

## 20. Conclusion

PredictX is designed as a modular decentralized prediction market protocol with AMM trading, tokenized outcomes, governance, oracle resolution, vault accounting, upgradeability, deterministic deployment, and automated security testing.

The architecture prioritizes:

- Clear separation of responsibilities
- Auditability
- Modularity
- Deterministic deployment
- Governance-controlled execution
- Testability across unit, fuzz, invariant, fork, and deployment layers