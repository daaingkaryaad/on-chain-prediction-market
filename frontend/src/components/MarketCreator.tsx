import { Contract, JsonRpcProvider } from "ethers";
import { useEffect, useState } from "react";

import { CONTRACTS } from "../config/contracts";
import FactoryAbi from "../abi/PredictionMarketFactory.json";

type Props = {
  readProvider: JsonRpcProvider;
  account: string;
};

export default function MarketCreator({ readProvider }: Props) {
  const [marketsCount, setMarketsCount] = useState("0");

  useEffect(() => {
    async function load() {
      const factory = new Contract(CONTRACTS.factory, FactoryAbi, readProvider);

      const count = await factory.getMarketsCount();
      setMarketsCount(count.toString());
    }

    void load();
  }, [readProvider]);

  return (
    <div className="card">
      <h2>Markets</h2>

      <p className="muted">
        Factory deployment is live on Base Sepolia. Market creation support is
        prepared through the deployed factory contract.
      </p>

      <div className="stat">
        <p className="label">Markets Count</p>
        <strong>{marketsCount}</strong>
      </div>

      <p className="muted">
        Full create-market UI can be wired to the factory once market parameters
        are finalized for demo flow.
      </p>
    </div>
  );
}
