export const STAKING_CONTRACT_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
export const STAKING_TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

export const STAKING_ABI = [
  "function stake(uint256 _amount) external",
  "function unstake(uint256 _stakeIndex) external",
  "function getStakeCount(address _user) external view returns (uint256)",
  "function getStakeInfo(address _user, uint256 _index) external view returns (uint256 amount, uint256 timestamp, uint256 unlockTime, bool claimed)",
  "function stakingToken() external view returns (address)"
];

export const ERC20_ABI = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function balanceOf(address account) external view returns (uint256)",
  "function allowance(address owner, address spender) external view returns (uint256)"
];