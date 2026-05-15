# PredictX Deployment Addresses

## Deployment Information

| Item | Value |
|---|---|
| Network | Base Sepolia |
| Chain ID | 84532 |
| Deployment Status | Pending |
| Verification Status | Pending |
| Deployer | TBD |
| Deployment Date | TBD |

---

# 1. Core Protocol Contracts

| Contract | Address | Verified |
|---|---|---|
| PredictionMarketFactory | `TBD` | ❌ |
| PredictionMarket Implementation | `TBD` | ❌ |
| PredictionMarketUpgradeable V1 | `TBD` | ❌ |
| PredictionMarketUpgradeable V2 | `TBD` | ❌ |
| GovernanceToken | `TBD` | ❌ |
| OutcomeToken | `TBD` | ❌ |
| LPToken | `TBD` | ❌ |
| FeeVault | `TBD` | ❌ |
| ProtocolGovernor | `TBD` | ❌ |
| ProtocolTimelock | `TBD` | ❌ |

---

# 2. Oracle Contracts

| Contract | Address | Verified |
|---|---|---|
| ChainlinkOracleAdapter | `TBD` | ❌ |
| MockOracleAdapter | `TBD` | ❌ |
| MockChainlinkAggregator | `TBD` | ❌ |

---

# 3. Proxy Contracts

## UUPS Proxy Deployment

| Contract | Proxy Address | Implementation | Verified |
|---|---|---|---|
| PredictionMarketUpgradeableProxy | `TBD` | `TBD` | ❌ |

---

# 4. Governance Configuration

| Parameter | Value |
|---|---|
| Voting Delay | 1 day |
| Voting Period | 1 week |
| Proposal Threshold | 1% |
| Quorum | 4% |
| Timelock Delay | 2 days |

---

# 5. Oracle Configuration

| Parameter | Value |
|---|---|
| Oracle Type | Chainlink |
| Stale Price Delay | TBD |
| Feed Decimals | TBD |
| Feed Address | TBD |

---

# 6. ERC4626 Vault Configuration

| Parameter | Value |
|---|---|
| Vault Type | ERC4626 |
| Asset Token | TBD |
| Fee Recipient | TBD |

---

# 7. CREATE2 Deployment Information

## Deterministic Deployment

The protocol supports deterministic market deployment using:

```text
CREATE2
CREATE2 Salt
Item	Value
Salt Strategy	keccak256(marketId)
Factory Address	TBD
Predicted Market Addresses
Market	Salt	Predicted Address
Example Market 1	TBD	TBD
Example Market 2	TBD	TBD
8. Verification Commands
Foundry Verification
forge verify-contract \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY \
  <CONTRACT_ADDRESS> \
  <CONTRACT_NAME>
Example
forge verify-contract \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY \
  0x0000000000000000000000000000000000000000 \
  src/core/PredictionMarket.sol:PredictionMarket
9. Deployment Scripts

Deployment scripts used:

script/Deploy.s.sol
script/DeployMocks.s.sol
10. Environment Variables

Required deployment variables:

PRIVATE_KEY=
BASE_RPC_URL=
BASESCAN_API_KEY=
11. Frontend Configuration

Frontend environment variables:

VITE_FACTORY_ADDRESS=
VITE_GOVERNOR_ADDRESS=
VITE_GOV_TOKEN_ADDRESS=
VITE_RPC_URL=
VITE_CHAIN_ID=84532
12. Subgraph Configuration

Subgraph deployment target:

The Graph

Subgraph endpoint:

TBD

Indexed contracts:

PredictionMarketFactory
PredictionMarket
OutcomeToken
LPToken
GovernanceToken
13. Deployment Checklist
Pre-Deployment
 Run forge test
 Run forge coverage
 Run forge snapshot
 Run Slither analysis
 Verify environment variables
 Verify deployer wallet funding
Deployment
 Deploy mock contracts
 Deploy governance token
 Deploy vault
 Deploy governor
 Deploy timelock
 Deploy factory
 Deploy upgradeable implementation
 Deploy proxy
 Configure permissions
 Transfer ownership
Post-Deployment
 Verify contracts
 Publish deployment addresses
 Configure frontend
 Deploy subgraph
 Execute governance ownership transfer
 Finalize admin permissions
14. Ownership Transfer Plan

Initial deployment uses temporary admin ownership.

Final production deployment should transfer privileged roles to governance-controlled timelock execution.

Roles to transfer:

Role	Final Owner
DEFAULT_ADMIN_ROLE	Timelock
RESOLVER_ROLE	Governance
UPGRADER_ROLE	Governance
MINTER_ROLE	Governance-controlled contracts
15. Deployment Notes
Upgradeability

The UUPS implementation was tested through:

V1 → V2 upgrade flow

Validated behaviors:

storage preservation
role preservation
version upgrades
unauthorized upgrade rejection
Security Status
Check	Status
Slither High Findings	0
Slither Medium Findings	0
Invariant Failures	0
Test Failures	0
16. Final Notes

This file serves as the canonical deployment registry for PredictX.

All production deployments, verified contract addresses, governance ownership transfers, and subgraph endpoints should be recorded here after deployment.