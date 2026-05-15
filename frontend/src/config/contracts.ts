export const CONTRACTS = {
  chainId: Number(import.meta.env.VITE_CHAIN_ID ?? 84532),
  rpcUrl: import.meta.env.VITE_RPC_URL ?? "https://sepolia.base.org",

  collateralToken:
    import.meta.env.VITE_COLLATERAL_TOKEN_ADDRESS ??
    "0xbA42AEeA2717Bb4bdBD7B80E8bEdc8b31B6BE8D2",

  factory:
    import.meta.env.VITE_FACTORY_ADDRESS ??
    "0xCF2A44203097275a975264a7C61798E12CE700aE",

  governanceToken:
    import.meta.env.VITE_GOVERNANCE_TOKEN_ADDRESS ??
    "0x2F6E705b05BE552D64272B84E85806163B087d03",

  governor:
    import.meta.env.VITE_GOVERNOR_ADDRESS ??
    "0x77b883238BAe5511935697B08080a4Dd90C9dCF8",

  timelock:
    import.meta.env.VITE_TIMELOCK_ADDRESS ??
    "0x59432A83AcF3dB27BB11b65a0271F9Df9c21074C",

  feeVault:
    import.meta.env.VITE_FEE_VAULT_ADDRESS ??
    "0x8E7e468e98a02e61eaD523709b82A86304A0E275",

  oracle:
    import.meta.env.VITE_ORACLE_ADDRESS ??
    "0x95E9428B717c80fb26588d65C64a4b37E299A8AC",

  subgraphUrl: import.meta.env.VITE_SUBGRAPH_URL ?? "",
};
