# PoC Internet Computer as a Data Availability for Arbitrum Nitro

*DISCLAIMER*: this repo shouln't ever, ever be assumed safe for production or even proper staging/testing environment. Use locally only.

## Run icda
1. Install dfx `sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"`
2. `apt install build-essential`
3. `cd icda`
4. `npm i`
5. `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
6. `dfx start --clean &`
7. `dfx deploy`
8. `dfx stop && dfx start`

## Run nitro

1. `cd icda-nitro`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. `./test-node.bash --dev --init`


## Run icdaserver

1. `cd icdaserver`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. 
