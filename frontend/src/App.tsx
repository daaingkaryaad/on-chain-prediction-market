import { BrowserProvider, JsonRpcProvider, Signer } from "ethers";
import { useCallback, useEffect, useMemo, useState } from "react";

import { CONTRACTS } from "./config/contracts";
import { BASE_SEPOLIA } from "./config/chain";

import WalletConnect from "./components/WalletConnect";
import ProtocolOverview from "./components/ProtocolOverview";
import VaultPanel from "./components/VaultPanel";
import GovernancePanel from "./components/GovernancePanel";
import MarketCreator from "./components/MarketCreator";
import SubgraphStats from "./components/SubgraphStats";

declare global {
  interface Window {
    ethereum?: any;
  }
}

export type WalletState = {
  account: string;
  chainId: number;
  signer: Signer | null;
};

export default function App() {
  const [wallet, setWallet] = useState<WalletState>({
    account: "",
    chainId: 0,
    signer: null,
  });

  const [error, setError] = useState("");

  const readProvider = useMemo(() => new JsonRpcProvider(CONTRACTS.rpcUrl), []);

  const connectWallet = useCallback(async () => {
    setError("");

    try {
      if (!window.ethereum) {
        setError("MetaMask is not installed.");
        return;
      }

      const browserProvider = new BrowserProvider(window.ethereum);
      const accounts = await browserProvider.send("eth_requestAccounts", []);
      const network = await browserProvider.getNetwork();
      const signer = await browserProvider.getSigner();

      setWallet({
        account: accounts[0],
        chainId: Number(network.chainId),
        signer,
      });
    } catch (err) {
      setError(readableError(err));
    }
  }, []);

  const switchNetwork = useCallback(async () => {
    setError("");

    try {
      if (!window.ethereum) {
        setError("MetaMask is not installed.");
        return;
      }

      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: BASE_SEPOLIA.chainIdHex }],
      });

      await connectWallet();
    } catch (err: any) {
      if (err?.code === 4902) {
        await window.ethereum.request({
          method: "wallet_addEthereumChain",
          params: [BASE_SEPOLIA],
        });
        await connectWallet();
        return;
      }

      setError(readableError(err));
    }
  }, [connectWallet]);

  useEffect(() => {
    if (!window.ethereum) {
      return;
    }

    const handleAccountsChanged = () => {
      void connectWallet();
    };

    const handleChainChanged = () => {
      void connectWallet();
    };

    window.ethereum.on("accountsChanged", handleAccountsChanged);
    window.ethereum.on("chainChanged", handleChainChanged);

    return () => {
      window.ethereum?.removeListener("accountsChanged", handleAccountsChanged);
      window.ethereum?.removeListener("chainChanged", handleChainChanged);
    };
  }, [connectWallet]);

  const wrongNetwork =
    wallet.account.length > 0 && wallet.chainId !== CONTRACTS.chainId;

  return (
    <main className="app">
      <section className="hero">
        <div>
          <p className="eyebrow">Base Sepolia prediction market protocol</p>
          <h1>PredictX</h1>
          <p className="heroText">
            On-chain binary prediction markets with CPMM trading, ERC1155
            outcome shares, ERC4626 vault accounting, Governor + Timelock DAO,
            and The Graph indexing.
          </p>
        </div>

        <WalletConnect
          account={wallet.account}
          chainId={wallet.chainId}
          wrongNetwork={wrongNetwork}
          onConnect={connectWallet}
          onSwitchNetwork={switchNetwork}
        />
      </section>

      {error && <div className="errorBox">{error}</div>}

      {wrongNetwork && (
        <div className="warningBox">
          Wrong network. Please switch to Base Sepolia.
        </div>
      )}

      <section className="grid">
        <ProtocolOverview
          readProvider={readProvider}
          account={wallet.account}
        />

        <VaultPanel
          signer={wallet.signer}
          readProvider={readProvider}
          account={wallet.account}
          disabled={!wallet.signer || wrongNetwork}
          onError={setError}
        />

        <GovernancePanel
          signer={wallet.signer}
          readProvider={readProvider}
          account={wallet.account}
          disabled={!wallet.signer || wrongNetwork}
          onError={setError}
        />

        <MarketCreator readProvider={readProvider} account={wallet.account} />

        <SubgraphStats />
      </section>
    </main>
  );
}

function readableError(err: unknown): string {
  const anyErr = err as any;

  if (anyErr?.code === 4001) {
    return "Transaction rejected in wallet.";
  }

  if (typeof anyErr?.shortMessage === "string") {
    return anyErr.shortMessage;
  }

  if (typeof anyErr?.reason === "string") {
    return anyErr.reason;
  }

  if (typeof anyErr?.message === "string") {
    return anyErr.message;
  }

  return "Unexpected error. The chain goblin refused to elaborate.";
}
