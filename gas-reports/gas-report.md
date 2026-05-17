# PredictX Gas & Bytecode Report

## Overview

This document summarizes gas consumption, bytecode size analysis, deployment costs, and optimization techniques used throughout the PredictX protocol.

The protocol was analyzed using:

```bash
forge snapshot
forge build --sizes
```

Target network:

```text
Base Sepolia
```

Compiler version:

```text
Solidity 0.8.24
```

---

## 1. Gas Optimization Strategy

The protocol applies several gas optimization techniques:

## 1. Gas Optimization Strategy

| Optimization | Usage |
|---|---|
| Custom Errors | Used instead of revert strings to reduce bytecode size and revert cost |
| Immutable Variables | Used for constructor-set addresses to avoid repeated storage reads |
| ERC1155 Outcome Shares | Avoids deploying separate YES/NO token contracts per market |
| Yul Assembly | Benchmarked arithmetic helpers |
| CREATE2 | Deterministic deployment and address precomputation |
| Compact Storage | Avoids unnecessary storage variables |
| ERC4626 | Uses standardized vault accounting instead of custom vault logic |
| via-ir + optimizer | Reduces bytecode size and improves generated code |

## 1.1 Security Tradeoffs Kept Despite Gas Cost

| Mechanism | Reason |
|---|---|
| SafeERC20 | Safer ERC20 interactions |
| AccessControl | Explicit role-based permissions |
| CEI Ordering | Safer state transition ordering |
| ReentrancyGuard | Protects user-facing state-changing flows |

## 1.2 Optimization Benchmarks and Design Tradeoffs

The project uses targeted optimization rather than unsafe micro-optimization. The most important before/after measurements are listed below.

| Area | Before | After | Result |
|---|---:|---:|---|
| Outcome share design | Separate ERC20-style outcome token per outcome | Shared ERC1155 `OutcomeToken` for YES/NO shares | Avoids deploying new token contracts per market |
| Arithmetic helper: `mulDiv()` | Solidity implementation: 5,756 gas | Yul implementation: 5,611 gas | 145 gas saved in benchmark |
| Arithmetic helper: `max()` | Solidity implementation: 5,634 gas | Yul implementation: 5,714 gas | Solidity cheaper; Yul not used blindly |
| Arithmetic helper: `min()` | Solidity implementation: 5,510 gas | Yul implementation: 5,700 gas | Solidity cheaper; benchmark documented |
| Revert handling | Revert strings | Custom errors | Lower bytecode size and cheaper reverts |
| Address reads | Storage variables | Immutable constructor-set addresses | Avoids repeated SLOADs for fixed dependencies |
| Market deployment | CREATE only | CREATE + CREATE2 | Adds deterministic deployment while preserving normal deployment |
| Vault logic | Custom vault accounting | ERC4626 standard vault accounting | Reduces custom code and audit surface |

---

## 2. Contract Runtime Sizes

All contracts remain below the EIP-170 runtime size limit.

EIP-170 runtime size limit:

```text
24,576 bytes
```

### Runtime Size Table

| Contract | Runtime Size | Runtime Margin |
|---|---:|---:|
| `PredictionMarket` | 6,758 B | 17,818 B |
| `PredictionMarketFactory` | 10,613 B | 13,963 B |
| `ProtocolGovernor` | 15,535 B | 9,041 B |
| `ProtocolTimelock` | 5,319 B | 19,257 B |
| `GovernanceToken` | 8,452 B | 16,124 B |
| `OutcomeToken` | 6,877 B | 17,699 B |
| `LPToken` | 3,035 B | 21,541 B |
| `FeeVault` | 5,073 B | 19,503 B |
| `ChainlinkOracleAdapter` | 907 B | 23,669 B |
| `MockOracleAdapter` | 2,009 B | 22,567 B |
| `MockERC20` | 2,279 B | 22,297 B |
| `PredictionMarketUpgradeable` | 3,803 B | 20,773 B |
| `PredictionMarketUpgradeableV2` | 3,896 B | 20,680 B |
| `YulMath` | 57 B | 24,519 B |

Largest contract:

```text
ProtocolGovernor.sol
15,535 bytes
```

Remaining EIP-170 margin:

```text
9,041 bytes
```

---

## 3. Base Sepolia Deployment Gas

The protocol was deployed and verified on Base Sepolia.

### Mock Deployment

| Contract | Gas Used | Gas Price | Paid |
|---|---:|---:|---:|
| `MockERC20` | 633,167 | 0.006481294 gwei | 0.000004103741478098 ETH |
| `MockOracleAdapter` | 567,120 | 0.006481294 gwei | 0.000003675671453280 ETH |

Total mock deployment:

```text
1,200,287 gas
0.000007779412931378 ETH
```

### Protocol Deployment

| Deployment Step | Gas Used | Gas Price | Paid |
|---|---:|---:|---:|
| `GovernanceToken` deployment | 2,108,412 | 0.006 gwei | 0.000012650472 ETH |
| `ProtocolTimelock` deployment | 1,321,550 | 0.006 gwei | 0.000007929300 ETH |
| `ProtocolGovernor` deployment | 2,391,690 | 0.006 gwei | 0.000014350140 ETH |
| Role configuration transaction | 51,246 | 0.006 gwei | 0.000000307476 ETH |
| `OutcomeToken` deployment | 1,628,241 | 0.006 gwei | 0.000009769446 ETH |
| Protocol deployment / configuration transaction | 3,579,148 | 0.006 gwei | 0.000021474888 ETH |
| `LPToken` deployment | 823,168 | 0.006 gwei | 0.000004939008 ETH |
| `FeeVault` deployment | 1,269,293 | 0.006 gwei | 0.000007615758 ETH |
| Role configuration transaction | 51,246 | 0.006 gwei | 0.000000307476 ETH |

Total protocol deployment:

```text
13,223,994 gas
0.000079343964 ETH
```

---

## 4. Key Runtime Gas Measurements

Gas values were collected from `forge snapshot`.

### PredictionMarket.sol

#### Trading Functions

| Function | Approx Gas |
|---|---:|
| `buyYes()` | ~145k |
| `buyNo()` | ~145k |
| `sellYes()` | ~168k |
| `sellNo()` | ~168k |

#### Liquidity Functions

| Function | Approx Gas |
|---|---:|
| `addLiquidity()` | ~121k |
| `removeLiquidity()` | ~134k |

#### Resolution and Claiming

| Function | Approx Gas |
|---|---:|
| `resolveMarket()` | ~120k |
| `claimRewards()` | ~235k |

### Governance

| Function / Flow | Approx Gas |
|---|---:|
| `delegate()` | ~87k |
| Full propose → vote → queue → execute lifecycle | ~302k |

### Factory Deployments

| Function | Approx Gas |
|---|---:|
| `createMarket()` | ~1.65M |
| `createMarketDeterministic()` | ~1.67M |

Deployment cost is higher due to:

- Market contract deployment
- ERC1155 outcome token linkage
- LP token integration
- Oracle configuration
- Role setup
- Governance compatibility

---

## 5. Yul Assembly Optimization

### YulMath.sol

The protocol includes isolated Yul-based arithmetic helpers for benchmarking and optimization demonstration.

Functions:

- `max()`
- `min()`
- `mulDiv()`

### Gas Comparison

#### `max()`

| Version | Gas |
|---|---:|
| Solidity | 5,634 |
| Yul | 5,714 |

Result:

```text
Solidity version is slightly cheaper in this benchmark.
```

#### `min()`

| Version | Gas |
|---|---:|
| Solidity | 5,510 |
| Yul | 5,700 |

Result:

```text
Solidity version is slightly cheaper in this benchmark.
```

#### `mulDiv()`

| Version | Gas |
|---|---:|
| Solidity | 5,756 |
| Yul | 5,611 |

Result:

```text
Yul version is cheaper in this benchmark.
```

### Assessment

The Yul implementation provides measurable improvement for `mulDiv()` but does not outperform Solidity for every simple arithmetic operation.

The protocol intentionally limits assembly usage to isolated mathematical helpers to preserve:

- Readability
- Auditability
- Testability
- Reduced security risk

This satisfies the inline Yul benchmarking requirement without spreading assembly into core protocol accounting logic.

---

## 6. ERC1155 Gas Advantages

Outcome shares use ERC1155 rather than deploying independent ERC20 contracts for every market outcome.

Advantages:

- Lower deployment overhead
- Lower storage duplication
- Shared approval system
- Batched transfer support
- Compact multi-market design
- Natural YES/NO outcome tokenization

This significantly reduces deployment and management costs compared to deploying separate token contracts for every market outcome.

---

## 7. CREATE2 Deployment Analysis

`PredictionMarketFactory.sol` supports deterministic market deployment through CREATE2.

Benefits:

- Predictable market addresses
- Off-chain address precomputation
- Improved frontend indexing
- Deterministic subgraph configuration
- Easier market discovery

CREATE2 has slightly higher complexity than standard CREATE, but the integration benefit is useful for prediction markets because frontend and indexing systems can precompute future market addresses.

---

## 8. ERC4626 Vault Efficiency

`FeeVault.sol` uses ERC4626 standardized vault accounting.

Benefits:

- Standardized asset/share accounting
- Reusable OpenZeppelin implementation
- Reduced custom vault logic
- Lower audit surface area
- Compatibility with existing DeFi tooling

Measured gas usage:

| Function | Approx Gas |
|---|---:|
| `deposit()` | ~98k |
| `withdraw()` | ~114k |
| `depositFees()` | ~49k |

---

## 9. Governance Gas Considerations

Governor-based governance introduces additional gas overhead because of:

- Vote checkpointing
- Quorum tracking
- Proposal lifecycle state transitions
- Calldata hashing
- Timelock queueing
- Timelock execution

This tradeoff is acceptable because governance operations are low-frequency but security-critical.

Governance gas is intentionally higher than simple admin calls because the protocol favors:

- Transparency
- Delayed execution
- Decentralization
- Auditability

---

## 10. L1 vs L2 Gas Comparison

The project is deployed on Base Sepolia as the selected L2 testnet.

The table below compares estimated gas units for common operations and expected cost behavior on L1 versus Base Sepolia.

| Operation | Gas Units | L1 Cost Profile | Base Sepolia Cost Profile |
|---|---:|---|---|
| Deploy `GovernanceToken` | 2,108,412 | High | Low |
| Deploy `ProtocolGovernor` | 2,391,690 | High | Low |
| Deploy `FeeVault` | 1,269,293 | High | Low |
| Deploy `OutcomeToken` | 1,628,241 | High | Low |
| `buyYes()` | ~145k | Medium | Low |
| `sellYes()` | ~168k | Medium | Low |
| `addLiquidity()` | ~121k | Medium | Low |
| `removeLiquidity()` | ~134k | Medium | Low |
| `createMarket()` | ~1.65M | High | Low |
| `createMarketDeterministic()` | ~1.67M | High | Low |

### L2 Assessment

Base Sepolia significantly reduces the ETH-denominated deployment and execution cost compared to Ethereum L1 while preserving EVM compatibility and block explorer verification support.

The deployment paid approximately:

```text
0.000079343964 ETH
```

for the main protocol deployment sequence on Base Sepolia.

### Cost Assumptions

This comparison uses gas units from `forge snapshot` / deployment output and illustrative gas prices:

| Network | Assumed Gas Price |
|---|---:|
| Ethereum L1 | 20 gwei |
| Base Sepolia | 0.006 gwei |

The exact ETH cost changes with network gas price, but the gas-unit comparison and relative cost difference remain useful.

| Operation | Gas Units | Est. L1 Cost @ 20 gwei | Est. Base Sepolia Cost @ 0.006 gwei |
|---|---:|---:|---:|
| Deploy `GovernanceToken` | 2,108,412 | 0.04216824 ETH | 0.000012650472 ETH |
| Deploy `ProtocolGovernor` | 2,391,690 | 0.04783380 ETH | 0.000014350140 ETH |
| Deploy `FeeVault` | 1,269,293 | 0.02538586 ETH | 0.000007615758 ETH |
| Deploy `OutcomeToken` | 1,628,241 | 0.03256482 ETH | 0.000009769446 ETH |
| `buyYes()` | 145,000 | 0.00290000 ETH | 0.000000870000 ETH |
| `sellYes()` | 168,000 | 0.00336000 ETH | 0.000001008000 ETH |
| `addLiquidity()` | 121,000 | 0.00242000 ETH | 0.000000726000 ETH |
| `removeLiquidity()` | 134,000 | 0.00268000 ETH | 0.000000804000 ETH |
| `createMarket()` | 1,650,000 | 0.03300000 ETH | 0.000009900000 ETH |
| `createMarketDeterministic()` | 1,670,000 | 0.03340000 ETH | 0.000010020000 ETH |

---

## 11. Storage Optimization

The protocol minimizes storage costs through:

| Technique | Description |
|---|---|
| Immutable variables | Removes repeated SLOAD operations for constructor-set addresses |
| Custom errors | Reduces bytecode size compared to revert strings |
| Compact enums | Efficient state representation |
| Role reuse | Shared AccessControl framework |
| Minimal upgrade storage | Reduced storage collision risk |
| ERC1155 token IDs | Avoids deploying separate ERC20 outcome tokens |
| CEI ordering | Reduces unnecessary defensive complexity |

---

## 12. Compiler Configuration

Compiler settings:

```toml
optimizer = true
optimizer_runs = 200
via_ir = true
```

Benefits:

- Reduced bytecode size
- Optimized arithmetic execution
- Improved deployment efficiency
- Avoidance of contract size limit failures

Coverage instrumentation may use different compiler settings than production builds; gas and bytecode measurements are therefore taken from `forge snapshot` and `forge build --sizes`, not from coverage output.

---

## 13. Gas Testing Methodology

Gas measurements were generated using:

```bash
forge snapshot
```

Bytecode sizes were generated using:

```bash
forge build --sizes
```

Deployment costs were collected from Base Sepolia broadcast output.

Gas benchmarks include:

- Unit tests
- Governance flows
- Upgrade flows
- AMM operations
- Vault interactions
- Yul vs Solidity comparisons
- Factory deployment flows

Gas snapshot artifact:

```text
.gas-snapshot
```
---

## 14. Post-Deployment Verification

The deployment was validated using:

```bash
forge script script/VerifyDeployment.s.sol:VerifyDeployment \
  --rpc-url base_sepolia
```

Output:

```text
Deployment verification passed.
Governor: 0x77b883238BAe5511935697B08080a4Dd90C9dCF8
Timelock: 0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C
Factory: 0xCF2A44203097275a975264a7C61798E12CE700aE
FeeVault: 0x8E7e468e98a02e61eaD523709b82A86304A0E275
```

The script validates:

- Governor voting delay
- Governor voting period
- Proposal threshold
- Timelock delay
- Governor proposer role
- Governor canceller role
- Deployed role configuration

---

## 15. Future Optimization Opportunities

Potential future improvements:

| Improvement | Impact |
|---|---|
| Packed storage structs | Reduced storage costs |
| Batch liquidity operations | Lower transaction overhead |
| Signature-based approvals | Fewer approval transactions |
| Permit2 integration | Improved UX and gas |
| Shared LP accounting | Reduced duplicate storage |
| Event indexing refinement | Better subgraph performance |
| Market parameter packing | Lower deployment/storage cost |

---

## 16. Conclusion

PredictX maintains:

- Safe runtime sizes
- Acceptable AMM execution costs
- Efficient governance execution
- Optimized token architecture
- Lightweight oracle adapters
- Low-cost Base Sepolia deployment
- Measurable Yul benchmarking
- Deterministic CREATE2 deployment support

The protocol remains comfortably below EIP-170 runtime limits while preserving modularity, readability, and auditability.