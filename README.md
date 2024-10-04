# PoC Internet Computer as a Data Availability for Arbitrum Nitro

*DISCLAIMER*: this repo shouln't ever, ever be assumed safe for production or even proper staging/testing environment. Use locally only.

## Setup
- `cd nitro-icda-poc`
- `chmod +x ./setup.sh`
- `./setup.sh`
It's an interactive shell, approve everything once promted

## Run icda (dfx instance and canister)
1. `cd icda`
2. `make all`

## Run icdaserver
1. `cd icdaserver`
2. `make all`
A `nitro-icda-poc/keyset.json` is generated and will be used in the next step. The terminal
might be block since `icdaserver` is running

## Run nitro
1. `cd nitro-icda/nitro-test`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. `./test-node.bash --dev --init`

## Register the keyset with an ethereum contract
1. docker run -v $(pwd)/keyset.json:/data/keyset/keyset-info.json --entrypoint /bin/sh nitro-node-dev-testnode -c "mkdir -p /data/keyset && datool dumpkeyset --conf.file /data/keyset/keyset-info.json" | grep 0x000 |sed 's/Keyset: //g' | xargs -I {} cast send --rpc-url http://localhost:8545 --private-key 0xdc04c5399f82306ec4b4d654a342f40e2e0620fe39950d967e1e574b32d4dd36 '0x18d19C5d3E685f5be5b9C86E097f0E439285D216' "setValidKeyset(bytes)" {}
This registers the keyset after serializing it to the needed encoding

