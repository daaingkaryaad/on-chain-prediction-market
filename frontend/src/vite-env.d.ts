/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_CHAIN_ID: string;
  readonly VITE_RPC_URL: string;

  readonly VITE_COLLATERAL_TOKEN_ADDRESS: string;
  readonly VITE_FACTORY_ADDRESS: string;
  readonly VITE_GOVERNANCE_TOKEN_ADDRESS: string;
  readonly VITE_GOV_TOKEN_ADDRESS: string;

  readonly VITE_GOVERNOR_ADDRESS: string;
  readonly VITE_TIMELOCK_ADDRESS: string;
  readonly VITE_FEE_VAULT_ADDRESS: string;
  readonly VITE_ORACLE_ADDRESS: string;

  readonly VITE_OUTCOME_TOKEN_ADDRESS: string;
  readonly VITE_LP_TOKEN_ADDRESS: string;

  readonly VITE_SUBGRAPH_URL: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}