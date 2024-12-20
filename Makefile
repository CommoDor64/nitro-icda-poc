SHELL := /bin/bash
.ONESHELL:
.EXPORT_ALL_VARIABLES:
.PHONY: all icda icdaserver icdadeploy run clean nitroicda

clean:
	docker rm -f icda || true && \
	docker rm -f icdaserver || true && \
	rm generated/keyset.json || true && \
	rmdir generated || true && \
	cd nitro-icda/nitro-testnode && docker compose down && \
	docker container prune --force
setup:
	apt update
	apt install jq
	curl -L https://foundry.paradigm.xyz | bash
	/root/.foundry/bin/foundryup

icda:
	cd icda && \
	docker build -t icda . && \
	docker run -d --name=icda --network=host icda

icdadeploy:
	sleep 10
	docker exec -it icda bash -c "dfx deploy icda_backend"

icdaserver:
	cd icdaserver && \
	docker build -t icdaserver . && \
	docker run -d -v \
		$(shell pwd)/generated/:/generated/ \
		--name=icdaserver \
		--network=host \
		-e DAS_NETWORK="http://127.0.0.1:4943/" \
  		-e DAS_CANISTER="bkyz2-fmaaa-aaaaa-qaaaq-cai" \
  		-e DAS_KEYSET_HASH="0xb2fd804a20ccbfcfcb4053db7349d066b5ce00b01a48128754d4131fd5aeb741" \
		icdaserver

setup-nitroicda:
	sleep 5
	PUBKEY=$$(cat generated/keyset.json | jq -r '.keyset.backends[0].pubkey') && \
	sed "s|{{PUBKEY}}|$$PUBKEY|g" nitro-icda/nitro-testnode/scripts/_config.ts > nitro-icda/nitro-testnode/scripts/config.ts

nitroicda:
	cd nitro-icda/nitro-testnode && \
	export NITRO_CONTRACTS_BRANCH=3fd3313 && \
	./test-node.bash --dev --init --detach

postsetup-nitroicda:
	@keyset_value=$$(docker run -v $$(pwd)/generated/keyset.json:/data/keyset/keyset-info.json \
		--entrypoint /bin/sh nitro-node-dev-testnode -c \
		"mkdir -p /data/keyset && datool dumpkeyset --conf.file /data/keyset/keyset-info.json" | \
		grep 0x000 | sed 's/Keyset: //g'); \
	docker run --network host ghcr.io/foundry-rs/foundry:latest "cast send \
		--rpc-url http://localhost:8545 \
		--private-key 0xdc04c5399f82306ec4b4d654a342f40e2e0620fe39950d967e1e574b32d4dd36 \
		'0x18d19C5d3E685f5be5b9C86E097f0E439285D216' \
		'setValidKeyset(bytes)' \
		$$keyset_value"
tx:
	cd nitro-icda/nitro-testnode && docker compose run scripts send-l2 --ethamount 1 --to l2owner --wait

all: icda icdadeploy icdaserver setup-nitroicda nitroicda postsetup-nitroicda
