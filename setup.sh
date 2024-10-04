#!/bin/bash

sudo apt update

echo "Installing build-essential..."
sudo apt install -y build-essential jq

echo "Installing Node.js and npm..."
sudo apt install -y nodejs npm

echo "Installing Go..."
sudo apt install -y golang

echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

echo "Adding wasm32 target for Rust..."
rustup target add wasm32-unknown-unknown

echo "Installing DFX..."
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
source "$HOME/.local/share/dfx/env"

echo "Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
foundryup
source /root/.bashrc

echo "Navigating to icda and installing npm dependencies..."
cd icda
npm install

echo "Installation and setup complete!"
