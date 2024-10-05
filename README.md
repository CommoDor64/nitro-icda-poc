# PoC Internet Computer as a Data Availability for Arbitrum Nitro

*DISCLAIMER*: this repo shouln't ever, ever be assumed safe for production or even proper staging/testing environment. Use locally only.

*NOTE 1*: ALL STEPS ARE CRUCIAL
*NOTE 2*: TESTED ONLY ON UBUNTU 22.04 on Hetzner servers with intel processor and 8C/16GB. If you have a similar setup (on Hetzner) consider to take a VM not located in europe. Hetzner proxies mess up the setup for some reason.

### Setup
- `cd nitro-icda-poc`
- `chmod +x ./setup.sh`
- `./setup.sh`

It's an interactive shell, approve everything once promted

### Run icda (dfx instance and canister)
1. `cd icda`
2. `make all`

### Run icdaserver
1. `cd icdaserver`
2. `make all`

A `nitro-icda-poc/keyset.json` is generated and will be used in the next step. The terminal
might be block since `icdaserver` is running

### Run nitro
1. `cd nitro-icda/nitro-test`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. Run `cat ../../keyset.json | jq .keyset.backends[0].pubkey` to get the serialized root key
4. Change the value in the field `pubkey` to the value printed in the last step in the following file and line
https://github.com/CommoDor64/nitro-testnode/blob/2091188d1ac4132efe9e8a8f89cac970a62071e6/scripts/config.ts#L178. 
5. `./test-node.bash --dev --init`

### Post Config (After Arbitrum Nitro is running and you can see sequencer output)
Once the nitro instance is up, and complaining about some error, do:

1. `cd nitro-icda/nitro-test`
2. `cp ../../keyset.json ./`
3. `foundryup`
4. `docker run -v $(pwd)/keyset.json:/data/keyset/keyset-info.json --entrypoint /bin/sh nitro-node-dev-testnode -c "mkdir -p /data/keyset && datool dumpkeyset --conf.file /data/keyset/keyset-info.json" | grep 0x000 |sed 's/Keyset: //g' | xargs -I {} cast send --rpc-url http://localhost:8545 --private-key 0xdc04c5399f82306ec4b4d654a342f40e2e0620fe39950d967e1e574b32d4dd36 '0x18d19C5d3E685f5be5b9C86E097f0E439285D216' "setValidKeyset(bytes)" {}`

This registers the keyset after serializing it to the needed encoding.
In this stage, you should have a working setup of all components:
1. Local IC instance with deployed contracts
2. Local Arbitrum + L1 instance with proper config
3. A DA server called icdaserver, acting as a proxy between IC and Arbitrum

### Play with it
1. `cd nitro-icda/nitro-test`
2. `docker compose run scripts send-l2 --ethamount 1 --to l2owner --wait` sends 1 ETH between two accounts. The transaction should find itself in a l2 block and eventually posted to the DA layer. Looking at the output from the terminals should show you that the operation is happening correctly

## Detailed Changelog
This repo contains 3 sub modules.
1. Arbitrum Nitro "fork"
2. IC contracts
3. DAServer as a proxy between the two

Porjects 2 and 3 are made from scratch and relatively short and simple to understand.
Project 1 Is a modified "fork" (not really a fork, but acts as one) that contains chagnes to the upstream Arbitrum.

You can view the changes here. The base of the diff was `77cd88d5` commit and was the latest stable version of Abitrum I could start my work with.
https://github.com/CommoDor64/nitro-icda/compare/77cd88d5..a04016d7

### Core Changes: 
1. `arbstate/daprovider/util.go` - changes to `RecoverPayloadFromDasBatch` function which was responsible to verify data returned from the DA layer when queried for the block data by the hash, aka `GetByHash`
https://github.com/CommoDor64/nitro-icda/compare/77cd88d5..a04016d7#diff-45e3945280328599b608711c381252e1a71b8e2f8e06e740246288799b6dbf51R222   
2. `das/aggregator.go` - changes to `Store` function. In the past each reply from each DAServer was verified, and then an aggregated signature was verified against the aggregated pubkeys. Now there is no need for that, this verification is the responsibility of the collection of signatures at the subnet level or a bit of it done in the IC agent library.
https://github.com/CommoDor64/nitro-icda/compare/77cd88d5..a04016d7#diff-d5c9f8115ac4cd287f2ecf9bcb3504da5d078449f40cce9af74d7dd8344621c6R331
4. BLS verification was done by the ethereum implementation library. This was not compatible with the one used in core IC. The root key from the network is encoded as a compressed one, while the ethereum implementation uses the uncompressed one. Conversion is possible, but considering the scope and time management, I couldn't get it to work after some time and decided to move on and replace the one from the sequencer side in-place.

### Misc Changes:
1. The structure of the project is very typical to go, using interfaces heavily. However some things are not abstracted and needed to be changed to fit. For example the publc key and signature types used are of a specific type provided by Ethereum's BLS library. Places in code that used this type are mostly swapped with a raw byte array/slice in order to accomedate the signature/rootkey provided by IC.
2. Instead of interfacing with the IC using the integrated DAServer, I created a new one, as it was faster to compile and test, and some changes were needed in order to verify things properly. It's important to mention that the new DAServer is following the exact same interface as the old one, and is interchangeable.



