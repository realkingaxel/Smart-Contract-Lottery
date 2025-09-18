// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./interactions.s.sol";
import {FundSubscription} from "./interactions.s.sol";
import {AddConsumer} from "./interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {
        DeployContract();
    }

    function DeployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();

        if (networkConfig.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (networkConfig.subscriptionId, networkConfig.vrfCoordinator) =
                createSubscription.createSubscription(networkConfig.vrfCoordinator, networkConfig.account);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                networkConfig.vrfCoordinator, networkConfig.subscriptionId, networkConfig.link, networkConfig.account
            );
        }

        vm.startBroadcast(networkConfig.account);
        Raffle raffle = new Raffle(
            networkConfig.entranceFee,
            networkConfig.interval,
            networkConfig.vrfCoordinator,
            networkConfig.gasLane,
            networkConfig.subscriptionId,
            networkConfig.callbackGasLimit
        );

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), networkConfig.vrfCoordinator, networkConfig.subscriptionId, networkConfig.account);

        return (raffle, helperConfig);
    }
}
