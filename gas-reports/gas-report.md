# PredictX Gas & Bytecode Report

## Overview

This document summarizes gas consumption, bytecode size analysis, and optimization techniques used throughout the PredictX protocol.

The protocol was analyzed using:

```bash
forge snapshot
forge build --sizes

Target network:

Base Sepolia

Compiler version:

Solidity 0.8.24
1. Gas Optimization Strategy

The protocol applies several gas optimization techniques:

Optimization	Usage
Custom Errors	Used across all contracts
Immutable Variables	Used for frequently accessed addresses
ERC1155	Multi-token outcome shares
Yul Assembly	Optimized arithmetic helpers
CREATE2	Deterministic deployment
SafeERC20	Minimal transfer wrappers
Compact Storage	Reduced storage slot usage
AccessControl	Role-based authorization
ERC4626	Standardized vault accounting
2. Contract Runtime Sizes

All contracts remain below:

EIP-170 runtime size limit: 24,576 bytes
Runtime Size Table
Contract	Runtime Size
PredictionMarket	6,758 B
PredictionMarketFactory	10,613 B
ProtocolGovernor	15,535 B
ProtocolTimelock	5,319 B
GovernanceToken	8,452 B
OutcomeToken	6,877 B
LPToken	3,035 B
FeeVault	5,073 B
ChainlinkOracleAdapter	907 B
PredictionMarketUpgradeable	3,803 B

Largest contract:

ProtocolGovernor.sol
15,535 bytes

Remaining EIP-170 margin:

9,041 bytes
3. Key Gas Measurements
PredictionMarket.sol
Trading Functions
Function	Approx Gas
buyYes()	~145k
buyNo()	~145k
sellYes()	~168k
sellNo()	~168k
Liquidity Functions
Function	Approx Gas
addLiquidity()	~121k
removeLiquidity()	~134k
Resolution & Claiming
Function	Approx Gas
resolveMarket()	~120k
claimRewards()	~235k
Governance
Function	Approx Gas
propose() lifecycle	~302k
delegate()	~87k
Factory Deployments
Function	Approx Gas
createMarket()	~1.65M
createMarketDeterministic()	~1.67M

Deployment cost is expectedly higher due to:

ERC1155 linkage
LP token integration
oracle configuration
role setup
governance compatibility
4. Yul Assembly Optimization
YulMath.sol

The protocol includes Yul-based arithmetic helpers for benchmarking and optimization demonstrations.

Functions:

max()
min()
mulDiv()
Gas Comparison
max()
Version	Gas
Solidity	5634
Yul	5714
min()
Version	Gas
Solidity	5510
Yul	5700
mulDiv()
Version	Gas
Solidity	5756
Yul	5611
Assessment

Yul optimization provides measurable improvements in arithmetic-heavy operations such as:

mulDiv()

The protocol intentionally limits assembly usage to isolated mathematical helpers to preserve readability and auditability.

5. ERC1155 Gas Advantages

Outcome shares use ERC1155 rather than deploying independent ERC20 contracts for each market.

Advantages:

lower deployment overhead
lower storage duplication
shared approval system
batched transfer support
compact multi-market design

This significantly reduces deployment and management costs.

6. CREATE2 Deployment Analysis

The factory supports deterministic deployment through CREATE2.

Benefits:

predictable market addresses
off-chain address precomputation
improved frontend indexing
deterministic integration support

Gas overhead compared to CREATE is minimal relative to deployment complexity.

7. ERC4626 Vault Efficiency

FeeVault.sol uses ERC4626 standardized vault accounting.

Benefits:

optimized accounting model
reusable OpenZeppelin implementation
reduced custom logic complexity
lower audit surface area

Measured gas usage:

Function	Approx Gas
deposit()	~98k
withdraw()	~114k
8. Governance Gas Considerations

Governor-based governance introduces additional gas overhead because of:

vote checkpointing
quorum tracking
proposal lifecycle state transitions
timelock queueing

This tradeoff is acceptable for protocol-level governance actions due to low execution frequency.

9. Storage Optimization

The protocol minimizes storage costs through:

Technique	Description
immutable variables	Removes repeated SLOAD operations
compact enums	Efficient state representation
role reuse	Shared access-control framework
minimal upgrade storage	Reduced collision risk
10. Compiler Configuration

Compiler settings:

optimizer = true
optimizer_runs = 200
via_ir = true

Benefits:

reduced bytecode size
optimized arithmetic execution
improved deployment efficiency

Coverage runs intentionally disable optimizer settings for accurate instrumentation.

11. Gas Testing Methodology

Gas measurements were generated using:

forge snapshot

Gas benchmarks include:

unit tests
governance flows
upgrade flows
AMM operations
vault interactions

All gas measurements were captured on Foundry local execution environments.

12. Future Optimization Opportunities

Potential future improvements:

Improvement	Impact
Packed storage structs	Reduced storage costs
Batch liquidity operations	Lower transaction overhead
Signature-based approvals	Fewer approval transactions
Permit2 integration	Improved UX and gas
Shared LP accounting	Reduced duplicate storage
13. Conclusion

PredictX maintains:

safe runtime sizes
acceptable AMM execution costs
efficient governance execution
optimized token architecture
lightweight oracle adapters

The protocol remains comfortably below EIP-170 runtime limits while preserving modularity, readability, and auditability.