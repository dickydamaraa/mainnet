#!/bin/bash

echo -e "\033[0;35m"
echo ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
echo ██░▄▄▄░█░▄▄▀█▀▄▄▀█░██░██░██░██░▄▄░█▀▄▄▀█░▄▄█▄░▄█░▄▄█░▄▄▀██
echo ██▄▄▄▀▀█░██░█░██░█░██░██░▀▀░██░█▀▀█░██░█▄▄▀██░██░▄▄█░▀▀▄██
echo ██░▀▀▀░█▄██▄██▄▄██▄▄█▄▄█▀▀▀▄██░▀▀▄██▄▄██▄▄▄██▄██▄▄▄█▄█▄▄██
echo ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ 
echo -e "\e[0m"


sleep 2

# set vars
if [ ! $NODENAME ]; then
    read -p "Enter your moniker: " MONIKER
    echo 'export MONIKER='$MONIKER >> $HOME/.bash_profile
fi
CHAIN_ID="planq_7070-2"
CHAIN_DENOM="aplanq"
BINARY="planqd"

echo '================================================='
echo -e "Node moniker: ${CYAN}$MONIKER${NC}"
echo -e "Chain id:     ${CYAN}$CHAIN_ID${NC}"
echo -e "Chain demon:  ${CYAN}$CHAIN_DENOM${NC}"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update & upgrade
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# install packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

echo - e "\e[1m\e[32m3. Installing Golang... \e[0m" && sleep 1
# install go
if ! [ -x "$(command -v go)" ]; then
cd $HOME
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
fi

echo -e "\e[1m\e[32m4. Downloading and building binaries... \e[0m" && sleep 1
# download and build binaries
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

cd
rm -rf planq
git clone https://github.com/planq-network/planq.git
cd planq
git fetch
git checkout v1.0.3
make install
mkdir -p $HOME/.planqd/cosmovisor/genesis/bin
mkdir -p ~/.planqd/cosmovisor/upgrades
cp ~/go/bin/planqd ~/.planqd/cosmovisor/genesis/bin

echo -e "\e[1m\e[32m5. Setting config... \e[0m" && sleep 1
planqd config chain-id $CHAIN_ID
planqd init $MONIKER  --chain-id $CHAIN_ID
planqd config keyring-backend file
planqd config node tcp://localhost:14657

# download genesis and addrbook
wget https://raw.githubusercontent.com/planq-network/networks/main/mainnet/genesis.json
mv genesis.json ~/.planqd/config/
planqd validate-genesis
wget -O $HOME/.planqd/config/addrbook.json "http://addr.planq.snollygoster.xyz/addrbook.json"

# Set minimum gas price , seeds , and peers
SEEDS=`curl -sL https://raw.githubusercontent.com/planq-network/networks/main/mainnet/seeds.txt | awk '{print $1}' | paste -s -d, -`
sed -i.bak -e "s/^seeds =.*/seeds = \"$SEEDS\"/" ~/.planqd/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.planqd/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.planqd/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0aplanq\"/;" ~/.planqd/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.planqd/config/config.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.planqd/config/config.toml
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book

# Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.planqd/config/app.toml

# Custom Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:14658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:14657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"14660\"%" $HOME/.planqd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1417\"%; s%^address = \":8080\"%address = \":1480\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:1490\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:1491\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:1445\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:1446\"%" $HOME/.planqd/config/app.toml

echo -e "\e[1m\e[32m6. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/planqd.service > /dev/null << EOF
[Unit]
Description=planq-mainnet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.planqd"
Environment="DAEMON_NAME=planqd"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl enable planqd && sudo systemctl daemon-reload
sudo systemctl restart planqd && sudo journalctl -u planqd -f -o cat

echo '=============== SETUP FINISHED ==================='
