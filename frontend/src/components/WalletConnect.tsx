type Props = {
  account: string;
  chainId: number;
  wrongNetwork: boolean;
  onConnect: () => Promise<void>;
  onSwitchNetwork: () => Promise<void>;
};

export default function WalletConnect({
  account,
  chainId,
  wrongNetwork,
  onConnect,
  onSwitchNetwork,
}: Props) {
  return (
    <div className="card walletCard">
      <h2>Wallet</h2>

      {account ? (
        <>
          <p className="label">Connected account</p>
          <p className="mono">{shortAddress(account)}</p>

          <p className="label">Chain ID</p>
          <p>{chainId || "Unknown"}</p>

          {wrongNetwork && (
            <button onClick={onSwitchNetwork}>Switch to Base Sepolia</button>
          )}
        </>
      ) : (
        <button onClick={onConnect}>Connect MetaMask</button>
      )}
    </div>
  );
}

function shortAddress(address: string): string {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}
