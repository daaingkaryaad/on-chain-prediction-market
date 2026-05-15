import { Contract, JsonRpcProvider, parseUnits, Signer } from "ethers";
import { useState } from "react";

import { CONTRACTS } from "../config/contracts";
import MockERC20Abi from "../abi/MockERC20.json";
import FeeVaultAbi from "../abi/FeeVault.json";

type Props = {
  signer: Signer | null;
  readProvider: JsonRpcProvider;
  account: string;
  disabled: boolean;
  onError: (message: string) => void;
};

export default function VaultPanel({
  signer,
  account,
  disabled,
  onError,
}: Props) {
  const [mintAmount, setMintAmount] = useState("1000");
  const [depositAmount, setDepositAmount] = useState("10");
  const [loading, setLoading] = useState("");

  async function mintCollateral() {
    if (!signer || !account) return;

    setLoading("Minting collateral...");
    onError("");

    try {
      const collateral = new Contract(
        CONTRACTS.collateralToken,
        MockERC20Abi,
        signer,
      );

      const tx = await collateral.mint(account, parseUnits(mintAmount, 18));
      await tx.wait();

      setLoading("Collateral minted.");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  async function approveAndDeposit() {
    if (!signer || !account) return;

    setLoading("Approving and depositing...");
    onError("");

    try {
      const collateral = new Contract(
        CONTRACTS.collateralToken,
        MockERC20Abi,
        signer,
      );

      const vault = new Contract(CONTRACTS.feeVault, FeeVaultAbi, signer);
      const amount = parseUnits(depositAmount, 18);

      const approveTx = await collateral.approve(CONTRACTS.feeVault, amount);
      await approveTx.wait();

      const depositTx = await vault.deposit(amount, account);
      await depositTx.wait();

      setLoading("Vault deposit complete.");
    } catch (err) {
      onError(readableError(err));
      setLoading("");
    }
  }

  return (
    <div className="card">
      <h2>Vault & Collateral</h2>
      <p className="muted">
        Write transactions: mint mock collateral, approve vault, deposit into
        ERC4626 vault.
      </p>

      <label>
        Mint amount
        <input
          value={mintAmount}
          onChange={(event) => setMintAmount(event.target.value)}
          placeholder="1000"
        />
      </label>

      <button
        disabled={disabled || loading.length > 0}
        onClick={mintCollateral}
      >
        Mint Mock Collateral
      </button>

      <label>
        Deposit amount
        <input
          value={depositAmount}
          onChange={(event) => setDepositAmount(event.target.value)}
          placeholder="10"
        />
      </label>

      <button
        disabled={disabled || loading.length > 0}
        onClick={approveAndDeposit}
      >
        Approve + Deposit
      </button>

      {loading && <p className="status">{loading}</p>}
    </div>
  );
}

function readableError(err: unknown): string {
  const anyErr = err as any;

  if (anyErr?.code === 4001) return "Transaction rejected in wallet.";
  if (typeof anyErr?.shortMessage === "string") return anyErr.shortMessage;
  if (typeof anyErr?.reason === "string") return anyErr.reason;
  if (typeof anyErr?.message === "string") return anyErr.message;

  return "Transaction failed.";
}
