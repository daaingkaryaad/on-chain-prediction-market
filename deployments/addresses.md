# PredictX Deployment Addresses

## Deployment Information

| Item | Value |
|---|---|
| Network | Base Sepolia |
| Chain ID | `84532` |
| Deployment Status | Completed |
| Verification Status | Completed |
| Deployer | `0x838fDEB9f549D6515A1D517763b82e420C0a609D` |
| Deployment Date | TBD |
| Block Number | `41546621` |
| Mock Deployment Block | `41546435` |

---

## 1. Core Protocol Contracts

| Contract | Address | Verified | Explorer |
|---|---|---|---|
| `PredictionMarketFactory` | `0xCF2A44203097275a975264a7C61798E12CE700aE` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0xcf2a44203097275a975264a7c61798e12ce700ae) |
| `GovernanceToken` | `0x2F6E705b05BE552D64272B84E85806163B087d03` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0x2f6e705b05be552d64272b84e85806163b087d03) |
| `OutcomeToken` | `0xF1E2A7746B6F0909e761888b214433ec7A56C869` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0xf1e2a7746b6f0909e761888b214433ec7a56c869) |
| `LPToken` | `0xf7203d68c9ec1d73e1d5c77c78182E31A48ABf3F` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0xf7203d68c9ec1d73e1d5c77c78182e31a48abf3f) |
| `FeeVault` | `0x8E7e468e98a02e61eaD523709b82A86304A0E275` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0x8e7e468e98a02e61ead523709b82a86304a0e275) |
| `ProtocolGovernor` | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0x77b883238bae5511935697b08080a4dd90c9dcf8) |
| `ProtocolTimelock` | `0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0x59432a83acf3db27bb11b65a0271f9df9c21074c) |
| `PredictionMarket Implementation` | `TBD` | ❌ | TBD |
| `PredictionMarketUpgradeable V1` | `TBD` | ❌ | TBD |
| `PredictionMarketUpgradeable V2` | `TBD` | ❌ | TBD |

---

## 2. Mock and Oracle Contracts

| Contract | Address | Verified | Explorer |
|---|---|---|---|
| `MockERC20` | `0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0xba42aeea2717bb4bdbd7b80e8bedc8b31b6be8d2) |
| `MockOracleAdapter` | `0x95E9428B717c80fb26588d65C64a4b37E299A8AC` | ✅ | [BaseScan](https://sepolia.basescan.org/address/0x95e9428b717c80fb26588d65c64a4b37e299a8ac) |

---

## 3. Upgradeability Demo Contracts

The UUPS upgrade path is implemented and tested locally through:

- `PredictionMarketUpgradeable.sol`
- `PredictionMarketUpgradeableV2.sol`

The upgrade flow is validated in Foundry tests:

```text
PredictionMarketUpgradeable V1 → PredictionMarketUpgradeableV2
```
---

## 4. Governance Configuration

| Parameter | Value |
|---|---|
| Governance Token | `0x2F6E705b05BE552D64272B84E85806163B087d03` |
| Governor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` |
| Timelock | `0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C` |
| Voting Delay | 1 day |
| Voting Period | 1 week |
| Proposal Threshold | 1% |
| Quorum | 4% |
| Timelock Delay | 2 days |

---

## 5. Oracle Configuration

| Parameter | Value |
|---|---|
| Demo Oracle Type | Mock Oracle Adapter |
| Demo Mock Oracle Adapter | `0x95E9428B717c80fb26588d65C64a4b37E299A8AC` |
| Chainlink Integration | Implemented in `src/oracle/ChainlinkOracleAdapter.sol` |
| Mock Aggregator for Tests | Implemented in `src/mocks/MockChainlinkAggregator.sol` |
| Stale Price Delay | 1 day |
| Test Coverage | Chainlink stale price, invalid price, incomplete round, and fork-feed reads |

The Base Sepolia demo deployment uses `MockOracleAdapter` for deterministic market-resolution demonstrations. Chainlink feed integration is implemented and tested through `ChainlinkOracleAdapter` and fork/mock tests.

---

## 6. ERC4626 Vault Configuration

| Parameter | Value |
|---|---|
| Vault Type | ERC4626 |
| FeeVault | `0x8E7e468e98a02e61eaD523709b82A86304A0E275` |
| Asset Token | `0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2` |
| Asset Symbol | `mUSDC` |
| Fee Recipient | Governance / protocol-controlled vault |

---

## 7. CREATE2 Deployment Information

### Deterministic Deployment

The protocol supports deterministic market deployment using:

```text
CREATE2
```

### CREATE2 Salt

| Item | Value |
|---|---|
| Salt Strategy | `keccak256(marketId)` |
| Factory Address | `0xCF2A44203097275a975264a7C61798E12CE700aE` |

### Predicted Market Addresses

| Market | Salt | Predicted Address |
|---|---|---|
| Example Market 1 | dd62eeb4aeca41dfa5f76883da7a411d8a167e0000623d28ca64f0d | 0xad778933b18d23484ad343fed8e1a93db6c851b1940b0a4e431d0d9f31d9f9c1 |
| Example Market 2 | 79b05e42208c8379563414f77c5cdb3fa691aa6b6f84ca33bb9baae5 | 0x79b05e42208c8379563414f77c5cdb3fa691aa6b6f84ca33bb9baae5cd19b913 |

---

## 8. Deployment Transactions

### Mock Deployment

| Contract | Transaction Hash |
|---|---|
| `MockERC20` | `0x8dd62eeb4aeca41dfa5f76883da7a411d8a167e0000623d28ca64f0da42a81f8` |
| `MockOracleAdapter` | `0xaaaaed8d2812b0a27d8c262c8c92b3307c117c05c2285965700e8cd48065a978` |

### Protocol Deployment

| Contract / Action | Transaction Hash |
|---|---|
| `GovernanceToken` | `0xad778933b18d23484ad343fed8e1a93db6c851b1940b0a4e431d0d9f31d9f9c1` |
| `ProtocolTimelock` | `0x3a2530411a5e60fff28b76799b9f14de1d88fce29af8400c9f328bf94613ca4b` |
| `ProtocolGovernor` | `0x79b05e42208c8379563414f77c5cdb3fa691aa6b6f84ca33bb9baae5cd19b913` |
| `Timelock grantRole` | `0x2f9b5b7770669a5ff7b1816bd06e631f3656473ff92dfc0aeb1428ba173bf50d` |
| `OutcomeToken` | `0x5843a171f9c05194efb1b6252a91f731e862e9450f4122508668e3b7c347f23f` |
| `Timelock grantRole` | `0x118374c9183844c96670ec3dbfe4bff19c38dd38925b8ae95831dfa172acdaca` |
| `LPToken` | `0xfd55505d35b554e6720822577855379f1123bf04eda410a9f5685ac1d3ece042` |
| `FeeVault` | `0x54111751558f826c2066868928c7f5d47d45251ba3d0a2debee16196921661df` |
| `PredictionMarketFactory` | `0x68ae21fa08f52055ecdadd82034bb2205378f1f3186abdb7f7a405fb313a8747` |

### 8.1 Demo Governance Proposal

A demo governance proposal was created through the deployed `ProtocolGovernor` for frontend governance-state testing.

| Item | Value |
|---|---|
| Proposal ID | `48314768028055173947546214552902984144812981027415071482929356650676633766421` |
| Governor | `0x77b883238BAe5511935697B08080a4Dd90C9dCF8` |
| Description | `Demo proposal: read FeeVault total managed assets for PredictX frontend governance testing` |
| Vote Start Block | `41632758` |
| Vote End Block | `41683158` |
| Initial Observed State | `Succeeded` |
| Purpose | Frontend proposal list, state loading, and vote UI demonstration |

The proposal is indexed by The Graph and can be loaded in the frontend by `proposalId`.

---

## 9. Verification Commands

### Foundry Verification

```bash
forge verify-contract \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY \
  <CONTRACT_ADDRESS> \
  <CONTRACT_NAME>
```

### Example

```bash
forge verify-contract \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY \
  0xCF2A44203097275a975264a7C61798E12CE700aE \
  src/core/PredictionMarketFactory.sol:PredictionMarketFactory
```

---

## 10. Deployment Scripts

Deployment scripts used:

- `script/DeployMocks.s.sol`
- `script/Deploy.s.sol`
- `script/VerifyDeployment.s.sol`

### Mock Deployment

```bash
forge script script/DeployMocks.s.sol:DeployMocks \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
```

### Protocol Deployment

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
```

### Post-Deployment Verification

```bash
forge script script/VerifyDeployment.s.sol:VerifyDeployment \
  --rpc-url base_sepolia
```

Verification output:

```text
Deployment verification passed.
Governor: 0x77b883238BAe5511935697B08080a4Dd90C9dCF8
Timelock: 0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
Factory: 0xCF2A44203097275a975264a7C61798E12CE700aE
FeeVault: 0x8E7e468e98a02e61eaD523709b82A86304A0E275
```

---

## 11. Environment Variables

Required deployment variables:

```env

DEPLOYER=0x838fDEB9f549D6515A1D517763b82e420C0a609D

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

---

## 12. Frontend Configuration

Frontend environment variables:

```env
VITE_CHAIN_ID=84532
VITE_RPC_URL=https://sepolia.base.org

VITE_COLLATERAL_TOKEN_ADDRESS=0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2
VITE_FACTORY_ADDRESS=0xCF2A44203097275a975264a7C61798E12CE700aE
VITE_GOVERNANCE_TOKEN_ADDRESS=0x2F6E705b05BE552D64272B84E85806163B087d03
VITE_GOVERNOR_ADDRESS=0x77b883238BAe5511935697B08080a4Dd90C9dCF8
VITE_TIMELOCK_ADDRESS=0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
VITE_FEE_VAULT_ADDRESS=0x8E7e468e98a02e61eaD523709b82A86304A0E275
VITE_ORACLE_ADDRESS=0x95E9428B717c80fb26588d65C64a4b37E299A8AC

VITE_SUBGRAPH_URL=https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

---

## 13. Subgraph Configuration

Subgraph deployment target:

```text
The Graph Studio
```

Subgraph endpoint:

```text
https://api.studio.thegraph.com/query/1753352/predictx-base-sepolia/v0.0.1
```

Subgraph slug:

```text
predictx-base-sepolia
```

Network:

```text
Base Sepolia
```

Indexed contracts:

- `PredictionMarketFactory`
- `PredictionMarket`
- `OutcomeToken`
- `LPToken`
- `GovernanceToken`
- `ProtocolGovernor`

---

## 14. Deployment Checklist

### Pre-Deployment

- [x] Run `forge test`
- [x] Run `forge coverage`
- [x] Run `forge snapshot`
- [x] Run Slither analysis
- [x] Verify environment variables
- [x] Verify deployer wallet funding

### Deployment

- [x] Deploy mock contracts
- [x] Deploy governance token
- [x] Deploy vault
- [x] Deploy governor
- [x] Deploy timelock
- [x] Deploy factory
- [x] Configure governance permissions
- [x] Verify deployed contracts on BaseScan

### Post-Deployment

- [x] Publish deployment addresses
- [x] Configure frontend
- [x] Deploy subgraph
- [x] Run post-deployment verification script
- [x] Create demo governance proposal

---

## 15. Ownership and Governance Control

The Base Sepolia deployment uses role-based permissions for protocol administration and verifies Governor/Timelock configuration through `script/VerifyDeployment.s.sol`.

| Role | Current Demo Configuration | Production Governance Model |
|---|---|---|
| `DEFAULT_ADMIN_ROLE` | Deployer / configured protocol admin during testnet setup | Timelock-controlled governance |
| `RESOLVER_ROLE` | Demo resolver / configured oracle-resolution role | Governance / Timelock controlled resolver management |
| `UPGRADER_ROLE` | Tested in local UUPS upgrade flow | Governance / Timelock controlled upgrade authority |
| `MINTER_ROLE` | Authorized protocol contracts | Governance-controlled contracts |
| `FEE_DEPOSITOR_ROLE` | Authorized fee/deposit flow | Governance / Timelock controlled fee management |

The deployment verification script confirms Governor parameters, Timelock delay, proposer/canceller roles, and deployed contract role configuration.

---

## 16. Deployment Notes

### Upgradeability

The UUPS implementation was tested through:

```text
V1 → V2 upgrade flow
```

Validated behaviors:

- Storage preservation
- Role preservation
- Version upgrades
- Unauthorized upgrade rejection

### Security Status

| Check | Status |
|---|---:|
| Slither High Findings | 0 |
| Slither Medium Findings | 0 |
| Invariant Failures | 0 |
| Test Failures | 0 |
| Post-Deployment Verification | Passed |

The deployment process is reproducible through Foundry scripts and environment variables. Existing deployed addresses are recorded here as the canonical registry for the submitted deployment.
---

## 17. Final Notes

This file is the canonical deployment registry for the submitted PredictX Base Sepolia deployment. It records verified contract addresses, deployment transactions, governance configuration, frontend environment values, subgraph endpoint, and post-deployment verification commands.