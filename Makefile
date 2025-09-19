-include .env

.PHONY: all test deploy

build :; forge build

test :; forge test

install :; forge install cyfrin/foundry-devops@df9f90b && forge install smartcontractkit/chainlink-brownie-contracts@12393bd && forge install foundry-rs/forge-std@v1.8.2 && forge install transmissions11/solmate@v6 

deploy :; forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC) --account mywallet --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv