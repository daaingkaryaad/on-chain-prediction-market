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

      const marketsCount = await factory.getMarketsCount();
      const totalManagedAssets = await vault.totalManagedAssets();

      if (!account) {
        setData((prev) => ({
          ...prev,
          marketsCount: marketsCount.toString(),
          totalManagedAssets: formatUnits(totalManagedAssets, 18),
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
        collateral.balanceOf(account),
        govToken.balanceOf(account),
        govToken.getVotes(account),
        govToken.delegates(account),
        vault.balanceOf(account),
      ]);

      setData({
        collateralBalance: formatUnits(collateralBalance, 18),
        governanceBalance: formatUnits(governanceBalance, 18),
        votingPower: formatUnits(votingPower, 18),
        delegate,
        vaultShares: formatUnits(vaultShares, 18),
        totalManagedAssets: formatUnits(totalManagedAssets, 18),
        marketsCount: marketsCount.toString(),
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

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="stat">
      <p className="label">{label}</p>
      <strong>{value}</strong>
    </div>
  );
}
