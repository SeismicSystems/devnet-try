#!/bin/bash

RPC_URL="https://node-2.seismicdev.net/rpc"
FAUCET_URL="https://faucet-2.seismicdev.net/"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

check_balance() {
    local address=$1
    local balance_json=$(curl -s -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{
            "jsonrpc":"2.0",
            "method":"eth_getBalance",
            "params":["'$address'", "latest"],
            "id":1
        }')

    local hex_result=$(echo "$balance_json" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    if [ "$hex_result" == "0x0" ]; then
        echo -e "${RED}Error: Address not funded. Please check if your faucet transaction went through.${NC}"
        echo -e "${RED}If the issue persists, message @lyronc on Telegram.${NC}"
        exit 1
    fi
}

dev_wallet() {
    print_step "1" "Generating new dev wallet"
    local keypair=$(cast wallet new)
    DEV_WALLET_ADDRESS=$(echo "$keypair" | grep "Address:" | awk '{print $2}')
    DEV_WALLET_PRIVKEY=$(echo "$keypair" | grep "Private key:" | awk '{print $3}')
    print_success "Success"

    print_step "2" "Funding wallet"
    echo -e "Please visit: ${GREEN}$FAUCET_URL${NC}"
    echo -e "Enter this address: ${GREEN}$DEV_WALLET_ADDRESS${NC}"
    echo -ne "${BLUE}Press Enter when done...${NC}"
    read -r

    print_step "3" "Verifying funds (takes a few seconds)"
    sleep 4
    check_balance "$DEV_WALLET_ADDRESS"
    print_success "Success"
}
