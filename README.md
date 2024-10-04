# PoC Internet Computer as a Data Availability for Arbitrum Nitro

*DISCLAIMER*: this repo shouln't ever, ever be assumed safe for production or even proper staging/testing environment. Use locally only.

## Run icda
1. Install dfx `sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"`
2. `source "$HOME/.local/share/dfx/env"`
3. `apt install build-essential`
4. `cd icda`
5. `apt install nodejs npm`
6. `npm i`
7. `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
8. `export "$HOME/.cargo/env"`
9. `rustup target add wasm32-unknown-unknown`
10. `dfx start --clean &`
11. `dfx deploy`
12. `dfx stop && dfx start`

## Run nitro

1. `cd icda-nitro`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. `./test-node.bash --dev --init`


## Run icdaserver

1. `cd icdaserver`
2. `export NITRO_CONTRACTS_BRANCH=3fd3313`
3. `apt install golang`
4. `curl -L https://foundry.paradigm.xyz | bash`
5. `source /root/.bashrc`
