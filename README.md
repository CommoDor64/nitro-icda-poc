# PoC Internet Computer as a Data Availability for Arbitrum Nitro

*DISCLAIMER*: this repo shouln't ever, ever be assumed safe for production or even proper staging/testing environment. Use locally only.

*NOTE 1*: ALL STEPS ARE CRUCIAL
*NOTE 2*: TESTED ONLY ON UBUNTU 22.04 on Hetzner servers with intel processor and 8C/16GB. If you have a similar setup (on Hetzner) consider to take a VM not located in europe. Hetzner proxies mess up the setup for some reason.

## What's included

1. A local (test) instance of the Internet Computer, with a smart contract that accepts Arbitrum blocks from a sequencer. This runs as the `icda` Docker container and effectively serves as the data availability committee.
1. A modified DA server component of Arbitrum, which forwards the requests to the `icda` container. This is the `icdaserver` component.
1. An Arbitrum testnet, together with a sequencer that has been modified to check slightly more complicated BLS signatures issued by Internet Computer smart contracts (in particular, signatures of Merkle trees with a certain structure).
1. Scripts which tie these together, passing the threshold BLS key of the Internet Computer test instance (`icda`) to the other components
1. Scripts that demonstrate submitting transactions.

## Dependencies
1. Have `docker` installed
2. Install minimal deps `apt update && apt install -y make jq`

## Run and Rerun
1. Clone this repo (might take couple of minutes) `git clone --recurse-submodules https://github.com/CommoDor64/nitro-icda-poc.git`
2. `cd nitro-icda-poc`
3. `make clean` should clean the old setup in case you have it running
4. Start the entire setup (icda, icdaserver and the arbitrum setup) `make all`

## Play with it

1. Run `docker logs nitro-testnode-sequencer-1` to watch the output of the Arbitrum sequencer
1. In a separate terminal, execute the following rule (from the `nitro-icda-poc` directory) which sends 1 ETH between addresses and triggers an Arbitrum block creation: `make tx`. See the expected happy path output below.
1. Modify the setup to delete and redeploy the Internet Computer test instance. This will change the threshold BLS key of the instance, and provoke signature verification errors on the sequencer.
    ```bash
    $ docker exec -it icda /bin/bash
    /icda# dfx stop
    # Here you need to wait for a minute or so until the TCP TIME_WAIT passes
    /icda# dfx start --clean --background
    /icda# dfx deploy icda_backend
    ```
    Now try `make tx` from a separate terminal again. See the failure path output below.

### Expected logs from Arbitrum (happy path)
Running `docker logs nitro-testnode-sequencer-1` should report no errors and look like the following log print:

```bash
sequencer-1      | INFO [10-07|08:51:18.308] Submitted transaction                    hash=0x96db74642288e08e8abe693b52dddd20e3db747be842c60b730985ce6b03fa20 from=0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E nonce=3 recipient=0x5E1497dD1f08C87b2d8FE23e9AAB6c1De833D927 value=1,000,000,000,000,000,000
poster-1         | INFO [10-07|08:51:20.140] created block                            l2Block=21 l2BlockHash=5a0e0e..817b8b
sequencer-1      | INFO [10-07|08:51:21.661] DataPoster sent transaction              nonce=3 hash=7dddc3..a5d766 feeCap=15,000,000,070 tipCap=1,500,000,000 blobFeeCap=<nil> gas=213,512
sequencer-1      | INFO [10-07|08:51:21.663] BatchPoster: batch sent                  sequenceNumber=4 from=20 to=22 prevDelayed=12 currentDelayed=13 totalSegments=4  numBlobs=0
staker-unsafe-1  | http://172.17.0.1:8080/get-by-hash/0xccdd09d5967e4d9bacdf8e1909aa8b05a10ec2c458d381cbd992f4045e3963af
sequencer-1      | http://172.17.0.1:8080/get-by-hash/0xccdd09d5967e4d9bacdf8e1909aa8b05a10ec2c458d381cbd992f4045e3963af
poster-1         | http://172.17.0.1:8080/get-by-hash/0xccdd09d5967e4d9bacdf8e1909aa8b05a10ec2c458d381cbd992f4045e3963af
staker-unsafe-1  | INFO [10-07|08:51:23.037] InboxTracker                             sequencerBatchCount=5 messageCount=22 l1Block=166,015 l1Timestamp=2024-10-07T08:51:18+0000
sequencer-1      | INFO [10-07|08:51:23.041] InboxTracker                             sequencerBatchCount=5 messageCount=22 l1Block=166,015 l1Timestamp=2024-10-07T08:51:18+0000
poster-1         | INFO [10-07|08:51:23.041] InboxTracker                             sequencerBatchCount=5 messageCount=22 l1Block=166,015 l1Timestamp=2024-10-07T08:51:18+0000
staker-unsafe-1  | INFO [10-07|08:51:23.046] created block                            l2Block=20 l2BlockHash=5a8156..9a3601
staker-unsafe-1  | INFO [10-07|08:51:24.045] Pruned message results:                  "first pruned key"=15 "last pruned key"=16
staker-unsafe-1  | INFO [10-07|08:51:24.046] created block                            l2Block=21 l2BlockHash=5a0e0e..817b8b
staker-unsafe-1  | INFO [10-07|08:51:24.046] Pruned expected block hashes:            "first pruned key"=15 "last pruned key"=16
staker-unsafe-1  | INFO [10-07|08:51:24.048] Pruned last batch messages:              "first pruned key"=15 "last pruned key"=16
staker-unsafe-1  | INFO [10-07|08:51:24.049] Pruned last batch delayed messages:      "first pruned key"=9  "last pruned key"=9
staker-unsafe-1  | INFO [10-07|08:51:25.743] creating node                            hash=d1f528..7ad158 lastNode=2 parentNode=2
staker-unsafe-1  | INFO [10-07|08:51:25.778] DataPoster sent transaction              nonce=5 hash=b33a7a..ab2bf2 feeCap=15,000,000,070 tipCap=1,500,000,000 blobFeeCap=<nil> gas=367,361
staker-unsafe-1  | INFO [10-07|08:51:27.006] successfully executed staker transaction hash=b33a7a..ab2bf2
sequencer-1      | INFO [10-07|08:51:33.051] Submitted transaction                    hash=0xbe08b8eeb31cec9dab16fb1ba648ce1d1fa9b4d21c90e97a13af3132106ba697 from=0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E nonce=4 recipient=0x5E1497dD1f08C87b2d8FE23e9AAB6c1De833D927 value=1,000,000,000,000,000,000
sequencer-1      | INFO [10-07|08:51:35.075] Submitted transaction                    hash=0xdc25925b96db1c111b3fefe5f14b051030b0e8130074f5266cb588af586faa63 from=0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E nonce=5 recipient=0x5E1497dD1f08C87b2d8FE23e9AAB6c1De833D927 value=1,000,000,000,000,000,000
poster-1         | INFO [10-07|08:51:35.148] created block                            l2Block=22 l2BlockHash=3ab71b..1f1762
poster-1         | INFO [10-07|08:51:36.148] created block                            l2Block=23 l2BlockHash=ee9f7b..a241c4
sequencer-1      | INFO [10-07|08:51:43.012] ExecutionEngine: Added DelayedMessages   pos=24 delayed=13 block-header="&{ParentHash:0xee9f7b0eaaf32f96fd80c29b6433c2a25ce0ebba745904f227f7b04dbba241c4 UncleHash:0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347 Coinbase:0xe2148eE53c0755215Df69b2616E552154EdC584f Root:0xab2366488ebca367c0ff06e976bba9a2d55caec527f03b59ae3e90537ee0c5dd TxHash:0xa5f9155875493bd0a548ee4f35555cbdcfcbc1a1fd10e71482e8bae4864794e7 ReceiptHash:0xf08cf5553e1dae52e3df19b356b8320e17c39fb055f635739c31052db5c3e45e Bloom:[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] Difficulty:+1 Number:+24 GasLimit:1125899906842624 GasUsed:0 Time:1728291095 Extra:[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] MixDigest:0x0000000000000000000000000002888b000000000000001e0000000000000000 Nonce:[0 0 0 0 0 0 0 14] BaseFee:+100000000 WithdrawalsHash:<nil> BlobGasUsed:<nil> ExcessBlobGas:<nil> ParentBeaconRoot:<nil>}"
```
Despite `docker logs nitro-testnode-sequencer-1` being the most important log, the following ones can give valueable information
1. `docker logs icda`
2. `docker logs icdaserver`

### Expected logs from Arbitrum (failure path)

This is the expected output of `docker logs nitro-testnode-sequencer-1` after the Internet Computer test instance is redeployed.

```
INFO [10-21|13:42:28.624] Submitted transaction                    hash=0x2fba5691ad84abb085f36f30bc19b574063a28fcc2133f01f84cad7a73309077 from=0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E nonce=2 reci
pient=0x5E1497dD1f08C87b2d8FE23e9AAB6c1De833D927 value=1,000,000,000,000,000,000                                                                                                                       
WARN [10-21|13:42:36.575] error posting batch                      err="signature verification failed"
```

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
3. BLS verification was done by the ethereum implementation library. This was not compatible with the one used in core IC. The root key from the network is encoded as a compressed one, while the ethereum implementation uses the uncompressed one. Conversion is possible, but considering the scope and time management, I couldn't get it to work after some time and decided to move on and replace the one from the sequencer side in-place.
`VerifyDataFromIC` is defined here https://github.com/CommoDor64/nitro-icda/compare/77cd88d5..a04016d7#diff-1b01f2f1b6d746e515fdc8b9cda5b3a4f1eda49f7202e8fc73c735998d3c61f0R23. At the moment (07.10.2024) it has couple of cuplicated to be cleaned ASAP

### Misc Changes:
1. The structure of the project is very typical to go, using interfaces heavily. However some things are not abstracted and needed to be changed to fit. For example the publc key and signature types used are of a specific type provided by Ethereum's BLS library. Places in code that used this type are mostly swapped with a raw byte array/slice in order to accomedate the signature/rootkey provided by IC.
2. Instead of interfacing with the IC using the integrated DAServer, I created a new one, as it was faster to compile and test, and some changes were needed in order to verify things properly. It's important to mention that the new DAServer is following the exact same interface as the old one, and is interchangeable.

## Legacy Setup - All from here until end of README is kept as a refernce and will be removed
### Setup
- `git clone --recurse-submodules https://github.com/CommoDor64/nitro-icda-poc.git`
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

### Run Arbitrum Nitro
1. `cd nitro-icda/nitro-test`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. Run `cat ../../keyset.json | jq .keyset.backends[0].pubkey` to get the serialized root key
4. Change the value in the field `pubkey` to the value printed in the last step in the following file and line
https://github.com/CommoDor64/nitro-testnode/blob/2091188d1ac4132efe9e8a8f89cac970a62071e6/scripts/config.ts#L178. 
5. `./test-node.bash --dev --init` *It will build Arbitrum Nitro for the first time and might take up to 15 minutes*

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
### TODO what happens when runs what when fails

### Play with it
1. `cd nitro-icda/nitro-test`
2. `docker compose run scripts send-l2 --ethamount 1 --to l2owner --wait` sends 1 ETH between two accounts. The transaction should find itself in a l2 block and eventually posted to the DA layer. Looking at the output from the terminals should show you that the operation is happening correctly


## Break it
A strong verification for the fact that block data is saved on and validated from the IC can be done by providing a faulty public key upon the initialization of Arbitrum.

On step 4 you have initialized Arbitrum Nitro with the correct public key:
  > Change the value in the field `pubkey` to the value printed in the last step in the following file and line
  > https://github.com/CommoDor64/nitro-testnode/blob/2091188d1ac4132efe9e8a8f89cac970a62071e6/scripts/config.ts#L178.

The base64 encoded faulty key can be for instance :`MIGCMB0GDSsGAQQBgtx8BQMBAgEGDCsGAQQBgtx8BQMCAQNhAJcsz6sQicY/V7hUM/7Up43ok3c+aPAu2BSOJUVVZF4qqj6bUdndAb8PBSTxx5wNXBL0S2fK5vBJFc/9pKncc3fr0TfTKUvb0fcZ/NeztDR32/hgNdfty7ezZR8aCt6/OA==`. Try that out by replacing it in the same file.
Remember to restart Arbitrum Afterwards
1. `make clean

*It will build Arbitrum Nitro again which might take couple of minutes*
