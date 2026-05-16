import { Contract, formatUnits, JsonRpcProvider } from "ethers";
import { useEffect, useState } from "react";

import { CONTRACTS } from "../config/contracts";
import MockERC20Abi from "../abi/MockERC20.json";
import GovernanceTokenAbi from "../abi/GovernanceToken.json";
import FeeVaultAbi from "../abi/FeeVault.json";
import FactoryAbi from "../abi/PredictionMarketFactory.json";

type Props = {
  readProvider: JsonRpcProvider;
  account: string;
};

export default function ProtocolOverview({ readProvider, account }: Props) {
  const [data, setData] = useState({
    collateralBalance: "0",
    governanceBalance: "0",
    votingPower: "0",
    delegate: "",
    vaultShares: "0",
    totalManagedAssets: "0",
    marketsCount: "0",
  });

  useEffect(() => {
    async function load() {
      const collateral = new Contract(
        CONTRACTS.collateralToken,
        MockERC20Abi,
        readProvider,
      );

      const govToken = new Contract(
        CONTRACTS.governanceToken,
        GovernanceTokenAbi,
        readProvider,
      );

      const vault = new Contract(CONTRACTS.feeVault, FeeVaultAbi, readProvider);
      const factory = new Contract(CONTRACTS.factory, FactoryAbi, readProvider);

      let marketsCount = "0";
      let totalManagedAssets = "0";

      try {
        const count = await factory.getMarketsCount();
        marketsCount = count.toString();
      } catch {
        marketsCount = "0";
      }

      try {
        const managedAssets = await vault.totalManagedAssets();
        totalManagedAssets = formatUnits(managedAssets, 18);
      } catch {
        totalManagedAssets = "0";
      }

      if (!account) {
        setData((prev) => ({
          ...prev,
          marketsCount,
          totalManagedAssets,
        }));
        return;
      }

      const [
        collateralBalance,
        governanceBalance,
        votingPower,
        delegate,
        vaultShares,
      ] = await Promise.all([
        safeRead(() => collateral.balanceOf(account), 0n),
        safeRead(() => govToken.balanceOf(account), 0n),
        safeRead(() => govToken.getVotes(account), 0n),
        safeRead(() => govToken.delegates(account), ""),
        safeRead(() => vault.balanceOf(account), 0n),
      ]);

      setData({
        collateralBalance: formatUnits(collateralBalance, 18),
        governanceBalance: formatUnits(governanceBalance, 18),
        votingPower: formatUnits(votingPower, 18),
        delegate,
        vaultShares: formatUnits(vaultShares, 18),
        totalManagedAssets,
        marketsCount,
      });
    }

    void load();
  }, [readProvider, account]);

  return (
    <div className="card">
      <h2>Protocol Overview</h2>

      <div className="statGrid">
        <Stat label="Markets Created" value={data.marketsCount} />
        <Stat label="Collateral Balance" value={data.collateralBalance} />
        <Stat label="Governance Balance" value={data.governanceBalance} />
        <Stat label="Voting Power" value={data.votingPower} />
        <Stat label="Vault Shares" value={data.vaultShares} />
        <Stat label="Vault Managed Assets" value={data.totalManagedAssets} />
      </div>

      {account && (
        <>
          <p className="label">Delegate</p>
          <p className="mono break">{data.delegate}</p>
        </>
      )}
    </div>
  );
}

async function safeRead<T>(read: () => Promise<T>, fallback: T): Promise<T> {
  try {
    return await read();
  } catch {
    return fallback;
  }
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="stat">
      <p className="label">{label}</p>
      <strong>{value}</strong>
    </div>
  );
}
