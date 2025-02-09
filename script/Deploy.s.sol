// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StakingToken.sol";
import "../src/TokenStaking.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        StakingToken token = new StakingToken();
        TokenStaking staking = new TokenStaking(address(token));
        
        // Print the addresses of the deployed contracts
        console.log("StakingToken deployed to:", address(token));
        console.log("TokenStaking deployed to:", address(staking));

        vm.stopBroadcast();
    }
}