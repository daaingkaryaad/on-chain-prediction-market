import { Contract, JsonRpcProvider, Signer } from "ethers";
import { useEffect, useState } from "react";

import { CONTRACTS } from "../config/contracts";
import GovernorAbi from "../abi/ProtocolGovernor.json";

type Proposal = {
  proposalId: string;
  proposer: string;
  description: string;
  voteStart: string;
  voteEnd: string;
  createdAt: string;
};

type Props = {
  signer: Signer | null;
  readProvider: JsonRpcProvider;
  disabled: boolean;
  onError: (message: string) => void;
};

const PROPOSALS_QUERY = `
  query GovernanceProposals {
    governanceProposals(first: 10, orderBy: createdAt, orderDirection: desc) {
      proposalId
      proposer
      description
      voteStart
      voteEnd
      createdAt
    }
  }
`;

const PROPOSAL_STATES = [
  "Pending",
  "Active",
  "Canceled",
  "Defeated",
  "Succeeded",
  "Queued",
  "Expired",
  "Executed",
];

export default function ProposalList({
  signer,
  readProvider,
  disabled,
  onError,
}: Props) {
  const [proposals, setProposals] = useState<Proposal[]>([]);
  const [selectedProposalId, setSelectedProposalId] = useState("");
  const [selectedSupport, setSelectedSupport] = useState("1");
  const [proposalState, setProposalState] = useState("");
  const [status, setStatus] = useState("Waiting for subgraph endpoint.");
  const [loading, setLoading] = useState("");

  useEffect(() => {
    async function loadProposals() {
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
          body: JSON.stringify({ query: PROPOSALS_QUERY }),
        });

        const json = await response.json();
        const nextProposals = json.data?.governanceProposals ?? [];

        setProposals(nextProposals);

        if (nextProposals.length === 0) {
          setStatus("No indexed governance proposals yet.");
        } else {
          setStatus("Governance proposals loaded from subgraph.");
        }
      } catch {
        setStatus("Could not load governance proposals from subgraph.");
      }
    }

    void loadProposals();
  }, []);

  async function loadProposalState(proposalId: string) {
    setLoading("Loading proposal state...");
    onError("");

    try {
      const governor = new Contract(
        CONTRACTS.governor,
        GovernorAbi,
        readProvider,
      );

      const stateId = await governor.state(proposalId);
      setSelectedProposalId(proposalId);
      setProposalState(PROPOSAL_STATES[Number(stateId)] ?? "Unknown");
      setLoading("");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  async function castVote() {
    if (!signer || !selectedProposalId) {
      return;
    }

    setLoading("Casting vote...");
    onError("");

    try {
      const governor = new Contract(CONTRACTS.governor, GovernorAbi, signer);
      const tx = await governor.castVote(
        selectedProposalId,
        Number(selectedSupport),
      );

      await tx.wait();

      setLoading("Vote submitted.");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  return (
    <div className="card wide">
      <h2>Governance Proposals</h2>
      <p className="muted">{status}</p>

      {proposals.length > 0 && (
        <div className="proposalList">
          {proposals.map((proposal) => (
            <div className="proposalItem" key={proposal.proposalId}>
              <div>
                <p className="label">Proposal ID</p>
                <p className="mono break">{proposal.proposalId}</p>
              </div>

              <p>{proposal.description}</p>

              <div className="statGrid">
                <div className="stat">
                  <p className="label">Proposer</p>
                  <strong className="mono break">
                    {shortAddress(proposal.proposer)}
                  </strong>
                </div>

                <div className="stat">
                  <p className="label">Vote Window</p>
                  <strong>
                    {proposal.voteStart} → {proposal.voteEnd}
                  </strong>
                </div>
              </div>

              <button onClick={() => loadProposalState(proposal.proposalId)}>
                Load On-Chain State
              </button>
            </div>
          ))}
        </div>
      )}

      {selectedProposalId && (
        <div className="proposalVoteBox">
          <h3>Selected Proposal</h3>
          <p className="mono break">{selectedProposalId}</p>

          {proposalState && (
            <p className="status">On-chain state: {proposalState}</p>
          )}

          <label>
            Vote
            <select
              value={selectedSupport}
              onChange={(event) => setSelectedSupport(event.target.value)}
            >
              <option value="0">Against</option>
              <option value="1">For</option>
              <option value="2">Abstain</option>
            </select>
          </label>

          <button disabled={disabled || loading.length > 0} onClick={castVote}>
            Cast Vote
          </button>
        </div>
      )}

      {loading && <p className="status">{loading}</p>}
    </div>
  );
}

function shortAddress(address: string): string {
  if (!address || address.length < 10) {
    return address;
  }

  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

function readableError(err: unknown): string {
  const anyErr = err as any;

  if (anyErr?.code === 4001) return "Transaction rejected in wallet.";
  if (typeof anyErr?.shortMessage === "string") return anyErr.shortMessage;
  if (typeof anyErr?.reason === "string") return anyErr.reason;
  if (typeof anyErr?.message === "string") return anyErr.message;

  return "Governance proposal action failed.";
}
