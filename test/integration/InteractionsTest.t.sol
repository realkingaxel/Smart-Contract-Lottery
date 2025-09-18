//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Vm} from "forge-std/Vm.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/interactions.s.sol";
import {console} from "forge-std/console.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract InteractionsTest is Test {
    HelperConfig public helperConfig;
    CreateSubscription public createSubscription;
    FundSubscription public fundSubscription;
    HelperConfig.NetworkConfig public config;
    AddConsumer public addConsumer;

    function setUp() public {
        fundSubscription = new FundSubscription();
        createSubscription = new CreateSubscription();
        helperConfig = new HelperConfig();
        addConsumer = new AddConsumer();
        config = helperConfig.getConfig();
    }

    //////////////////////////////////////////////////////////////////////////
    //                getConfig TESTS
    //////////////////////////////////////////////////////////////////////////

    function testGetConfigLocal() public {
        vm.chainId(31337);
        HelperConfig.NetworkConfig memory localconfig = helperConfig.getConfig();
        assert(localconfig.vrfCoordinator != address(0));
        assert(localconfig.vrfCoordinator != address(0));
        assert(localconfig.link != address(0));
        assert(localconfig.subscriptionId == 0);
        assert(localconfig.account != address(0));
        assert(localconfig.entranceFee == 0.01 ether);
        assert(localconfig.interval == 30);
        assert(localconfig.gasLane != bytes32(0));
        assert(localconfig.callbackGasLimit == 500000);
    }

    function testGetConfigSepolia() public {
        vm.chainId(11155111);
        HelperConfig.NetworkConfig memory sepoliaConfig = helperConfig.getConfig();
        assert(sepoliaConfig.vrfCoordinator != address(0));
        assert(sepoliaConfig.link != address(0));
        assert(sepoliaConfig.subscriptionId == 60795102219225105317606911915945976794363532223707470219973955864490482482065);
        assert(sepoliaConfig.account != address(0));
        assert(sepoliaConfig.entranceFee == 0.01 ether);
        assert(sepoliaConfig.interval == 30);
        assert(sepoliaConfig.gasLane != bytes32(0));
        assert(sepoliaConfig.callbackGasLimit == 500000);
    }

    //////////////////////////////////////////////////////////////////////////
    //                createSubscription TESTS
    //////////////////////////////////////////////////////////////////////////

    function testCreateSubscriptionUsingConfig() public {
        (uint256 subId,) = createSubscription.CreateSubscriptionUsingConfig();
        assert(subId > 0);
    }

    function testCreateSubscriptionfunction() public {
        (uint256 subId, address vrfCoordinator) =
            createSubscription.createSubscription(config.vrfCoordinator, config.account);
        assert(subId > 0);
        assert(vrfCoordinator == config.vrfCoordinator);
    }

    //////////////////////////////////////////////////////////////////////////
    //                FundSubscription TESTS
    //////////////////////////////////////////////////////////////////////////

    modifier subscriptionCreated() {
        (uint256 subId,) = createSubscription.createSubscription(config.vrfCoordinator, config.account);
        config.subscriptionId = subId;
        _;
    }

    function testfundSubscription() public subscriptionCreated {
        fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link, config.account);
        (uint96 balance,,,,) = VRFCoordinatorV2_5Mock(config.vrfCoordinator).getSubscription(config.subscriptionId);
        if (block.chainid == 31337) {
            assert(balance == 300 ether);
        } else {
            assert(balance == 3 ether);
        }
        console.log("Subscription balance:", balance);
    }

    //////////////////////////////////////////////////////////////////////////
    //                AddConsumer TESTS
    //////////////////////////////////////////////////////////////////////////

    function testAddConsumer() public subscriptionCreated {
        addConsumer.addConsumer(address(56), config.vrfCoordinator, config.subscriptionId, config.account);
        (,,,, address[] memory consumers) =
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).getSubscription(config.subscriptionId);
        assert(consumers[0] == address(56));
        console.log("Consumer added:", consumers[0]);
    }

    //////////////////////////////////////////////////////////////////////////
    //                DeployContract TESTS
    //////////////////////////////////////////////////////////////////////////

    function testDeployContract() public {
        DeployRaffle deployer = new DeployRaffle();
        (Raffle raffle,) = deployer.DeployContract();
        assert(address(raffle) != address(0));

        console.log("Raffle deployed at:", address(raffle));
    }
}
