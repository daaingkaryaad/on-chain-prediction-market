import { useEffect, useState } from "react";

import { CONTRACTS } from "../config/contracts";

type ProtocolStats = {
  totalMarkets: string;
  totalTrades: string;
  totalVolume: string;
  totalLiquidityAdded: string;
  totalLiquidityRemoved: string;
  totalRewardsClaimed: string;
};

const PROTOCOL_STATS_QUERY = `
  query ProtocolStats {
    protocolStats(id: "predictx") {
      totalMarkets
      totalTrades
      totalVolume
      totalLiquidityAdded
      totalLiquidityRemoved
      totalRewardsClaimed
    }
    markets(first: 5, orderBy: createdAt, orderDirection: desc) {
      id
      question
      marketAddress
      totalVolume
      resolved
      winningOutcome
    }
  }
`;

export default function SubgraphStats() {
  const [stats, setStats] = useState<ProtocolStats | null>(null);
  const [markets, setMarkets] = useState<any[]>([]);
  const [status, setStatus] = useState("Waiting for subgraph endpoint.");

  useEffect(() => {
    async function load() {
      if (!CONTRACTS.subgraphUrl) {
        setStatus("Subgraph URL is not configured yet.");
        return;
      }

      try {
        const response = await fetch(CONTRACTS.subgraphUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ query: PROTOCOL_STATS_QUERY }),
        });

        const json = await response.json();

        setStats(json.data?.protocolStats ?? null);
        setMarkets(json.data?.markets ?? []);
        setStatus("Subgraph data loaded.");
      } catch {
        setStatus("Could not load subgraph data.");
      }
    }

    void load();
  }, []);

  return (
    <div className="card wide">
      <h2>The Graph Indexing</h2>
      <p className="muted">{status}</p>

      {stats && (
        <div className="statGrid">
          <Stat label="Indexed Markets" value={stats.totalMarkets} />
          <Stat label="Indexed Trades" value={stats.totalTrades} />
          <Stat label="Total Volume" value={stats.totalVolume} />
          <Stat label="Liquidity Added" value={stats.totalLiquidityAdded} />
          <Stat label="Liquidity Removed" value={stats.totalLiquidityRemoved} />
          <Stat label="Rewards Claimed" value={stats.totalRewardsClaimed} />
        </div>
      )}

      {markets.length > 0 && (
        <div className="marketList">
          <h3>Latest Indexed Markets</h3>

          {markets.map((market) => (
            <div className="marketItem" key={market.id}>
              <strong>{market.question}</strong>
              <p className="mono break">{market.marketAddress}</p>
              <p>
                Volume: {market.totalVolume} | Resolved:{" "}
                {market.resolved ? "Yes" : "No"}
              </p>
            </div>
          ))}
        </div>
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
