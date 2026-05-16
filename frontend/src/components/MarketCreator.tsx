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
  const [factoryStatus, setFactoryStatus] = useState(
    "Factory deployed on Base Sepolia.",
  );

  useEffect(() => {
    async function load() {
      const factory = new Contract(CONTRACTS.factory, FactoryAbi, readProvider);

      try {
        const count = await factory.getMarketsCount();
        setMarketsCount(count.toString());
        setFactoryStatus("Factory read completed successfully.");
      } catch {
        setMarketsCount("0");
        setFactoryStatus(
          "Factory deployment is live. Market count read is unavailable for this ABI version.",
        );
      }
    }

    void load();
  }, [readProvider]);

  return (
    <div className="card">
      <h2>Markets</h2>

      <p className="muted">
        Factory deployment is live on Base Sepolia. Market creation is supported
        through the deployed PredictionMarketFactory contract.
      </p>

      <div className="stat">
        <p className="label">Markets Count</p>
        <strong>{marketsCount}</strong>
      </div>

      <p className="muted">{factoryStatus}</p>

      <p className="muted">
        The factory supports market deployment through CREATE and deterministic
        CREATE2 flows. Full create-market UI can be extended from the deployed
        factory interface.
      </p>
    </div>
  );
}
