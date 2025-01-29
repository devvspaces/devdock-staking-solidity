import { useState } from 'react';
import { ethers } from 'ethers';
import { useAccount, useContract, useSigner } from 'wagmi';
import { STAKING_CONTRACT_ADDRESS, STAKING_ABI, STAKING_TOKEN_ADDRESS, ERC20_ABI } from '../constants';

export const StakingForm = () => {
  const [amount, setAmount] = useState('');
  const signer } = useSigner();

  const stakingContract = useContract({
    address: STAKING_CONTRACT_ADDRESS,
    abi: STAKING_ABI,
    signerOrProvider: signer
  });

  const tokenContract = useContract({
    address: STAKING_TOKEN_ADDRESS,
    abi: ERC20_ABI,
    signerOrProvider: signer
  });

  const handleStake = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!stakingContract || !tokenContract || !address) return;

    try {
      const amountWei = ethers.utils.parseEther(amount);
      
      // First approve the staking contract
      const approveTx = await tokenContract.approve(STAKING_CONTRACT_ADDRESS, amountWei);
      await approveTx.wait();

      // Then stake
      const stakeTx = await stakingContract.stake(amountWei);
      await stakeTx.wait();
      
      setAmount('');
      alert('Staking successful!');
    } catch (error) {
      console.error('Error:', error);
      alert('Error staking tokens');
    }
  };

  return (
    <form onSubmit={handleStake}>
      <input
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount to stake"
        min="100"
      />
      <button type="submit">Stake</button>
    </form>
  );
};