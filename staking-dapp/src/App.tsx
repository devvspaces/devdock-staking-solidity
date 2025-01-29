import { WagmiConfig, createConfig, configureChains, sepolia } from 'wagmi';
import { publicProvider } from 'wagmi/providers/public';
import { MetaMaskConnector } from 'wagmi/connectors/metaMask';
import { StakingForm } from './components/StakingForm';
import { StakeList } from './components/StakeList';

const { chains, publicClient, webSocketPublicClient } = configureChains(
  [sepolia],
  [publicProvider()]
);

const config = createConfig({
  autoConnect: true,
  connectors: [
    new MetaMaskConnector({ chains })
  ],
  publicClient,
  webSocketPublicClient,
});

function App() {
  return (
    <WagmiConfig config={config}>
      <div>
        <h1>Token Staking DApp</h1>
        <StakingForm />
        <StakeList />
      </div>
    </WagmiConfig>
  );
}

export default App;