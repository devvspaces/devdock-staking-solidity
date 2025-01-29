import { useEffect, useState } from 'react';
import { useAccount, useContract, useProvider } from 'wagmi';
import { STAKING_CONTRACT_ADDRESS, STAKING_ABI } from '../constants';
import { ethers } from 'ethers';

interface StakeInfo {
  amount: string;
  timestamp: number;
  unlockTime: number;
  claimed: boolean;
}

export const StakeList = () => {
  const [stakes, setStakes] = useState<StakeInfo[]>([]);
  const { address } = useAccount();
  const provider = useProvider();

  const stakingContract = useContract({
    address: STAKING_CONTRACT_ADDRESS,
    abi: STAKING_ABI,
    signerOrProvider: provider
  });

  useEffect(() => {
    const fetchStakes = async () => {
      if (!stakingContract || !address) return;

      try {
        const stakeCount = await stakingContract.getStakeCount(address);
        const stakesPromises = [];

        for (let i = 0; i < stakeCount.toNumber(); i++) {
          stakesPromises.push(stakingContract.getStakeInfo(address, i));
        }

        const stakesData = await Promise.all(stakesPromises);
        const formattedStakes = stakesData.map(stake => ({
          amount: ethers.utils.formatEther(stake.amount),
          timestamp: stake.timestamp.toNumber(),
          unlockTime: stake.unlockTime.toNumber(),
          claimed: stake.claimed
        }));

        setStakes(formattedStakes);
      } catch (error) {
        console.error('Error fetching stakes:', error);
      }
    };

    fetchStakes();
  }, [address, stakingContract]);

  return (
    <div>
      <h2>Your Stakes</h2>
      {stakes.map((stake, index) => (
        <div key={index}>
          <p>Amount: {stake.amount} tokens</p>
          <p>Unlock Time: {new Date(stake.unlockTime * 1000).toLocaleString()}</p>
          <p>Status: {stake.claimed ? 'Claimed' : 'Active'}</p>
        </div>
      ))}
    </div>
  );
};