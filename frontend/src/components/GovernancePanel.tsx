import { Contract, formatUnits, JsonRpcProvider, Signer } from "ethers";
import { useEffect, useState } from "react";

import { CONTRACTS } from "../config/contracts";
import GovernanceTokenAbi from "../abi/GovernanceToken.json";
import GovernorAbi from "../abi/ProtocolGovernor.json";

type Props = {
  signer: Signer | null;
  readProvider: JsonRpcProvider;
  account: string;
  disabled: boolean;
  onError: (message: string) => void;
};

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

export default function GovernancePanel({
  signer,
  readProvider,
  account,
  disabled,
  onError,
}: Props) {
  const [delegatee, setDelegatee] = useState("");
  const [proposalId, setProposalId] = useState("");
  const [support, setSupport] = useState("1");
  const [proposalState, setProposalState] = useState("");
  const [governorInfo, setGovernorInfo] = useState({
    name: "",
    votingDelay: "",
    votingPeriod: "",
    proposalThreshold: "",
  });
  const [loading, setLoading] = useState("");

  useEffect(() => {
    async function load() {
      const governor = new Contract(
        CONTRACTS.governor,
        GovernorAbi,
        readProvider,
      );

      const [name, votingDelay, votingPeriod, proposalThreshold] =
        await Promise.all([
          governor.name(),
          governor.votingDelay(),
          governor.votingPeriod(),
          governor.proposalThreshold(),
        ]);

      setGovernorInfo({
        name,
        votingDelay: votingDelay.toString(),
        votingPeriod: votingPeriod.toString(),
        proposalThreshold: formatUnits(proposalThreshold, 18),
      });
    }

    void load();
  }, [readProvider]);

  async function delegateVotes() {
    if (!signer) return;

    setLoading("Delegating votes...");
    onError("");

    try {
      const token = new Contract(
        CONTRACTS.governanceToken,
        GovernanceTokenAbi,
        signer,
      );

      const tx = await token.delegate(delegatee || account);
      await tx.wait();

      setLoading("Delegation complete.");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  async function loadProposalState() {
    setLoading("Loading proposal state...");
    onError("");

    try {
      const governor = new Contract(
        CONTRACTS.governor,
        GovernorAbi,
        readProvider,
      );

      const stateId = await governor.state(proposalId);
      setProposalState(PROPOSAL_STATES[Number(stateId)] ?? "Unknown");
      setLoading("");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  async function castVote() {
    if (!signer) return;

    setLoading("Casting vote...");
    onError("");

    try {
      const governor = new Contract(CONTRACTS.governor, GovernorAbi, signer);
      const tx = await governor.castVote(proposalId, Number(support));
      await tx.wait();

      setLoading("Vote submitted.");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  return (
    <div className="card">
      <h2>Governance</h2>

      <div className="statGrid">
        <Stat label="Governor" value={governorInfo.name || "Loading"} />
        <Stat label="Voting Delay" value={governorInfo.votingDelay} />
        <Stat label="Voting Period" value={governorInfo.votingPeriod} />
        <Stat
          label="Proposal Threshold"
          value={governorInfo.proposalThreshold}
        />
      </div>

      <label>
        Delegatee address
        <input
          value={delegatee}
          onChange={(event) => setDelegatee(event.target.value)}
          placeholder={account || "0x..."}
        />
      </label>

      <button disabled={disabled || loading.length > 0} onClick={delegateVotes}>
        Delegate Voting Power
      </button>

      <hr />

      <label>
        Proposal ID
        <input
          value={proposalId}
          onChange={(event) => setProposalId(event.target.value)}
          placeholder="Proposal ID"
        />
      </label>

      <button disabled={!proposalId} onClick={loadProposalState}>
        Load Proposal State
      </button>

      {proposalState && (
        <p className="status">Proposal state: {proposalState}</p>
      )}

      <label>
        Vote
        <select
          value={support}
          onChange={(event) => setSupport(event.target.value)}
        >
          <option value="0">Against</option>
          <option value="1">For</option>
          <option value="2">Abstain</option>
        </select>
      </label>

      <button disabled={disabled || !proposalId} onClick={castVote}>
        Cast Vote
      </button>

      {loading && <p className="status">{loading}</p>}
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="stat">
      <p className="label">{label}</p>
      <strong>{value || "0"}</strong>
    </div>
  );
}

function readableError(err: unknown): string {
  const anyErr = err as any;

  if (anyErr?.code === 4001) return "Transaction rejected in wallet.";
  if (typeof anyErr?.shortMessage === "string") return anyErr.shortMessage;
  if (typeof anyErr?.reason === "string") return anyErr.reason;
  if (typeof anyErr?.message === "string") return anyErr.message;

  return "Governance transaction failed.";
}
