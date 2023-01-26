<p style="font-size:14px" align="right">
<a href="https://t.me/dickydamara" target="_blank">Contact me on Telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discordapp.com/users/392347017818669056" target="_blank">Contact me on Discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://twitter.com/snollyygoster" target="_blank">Contact me on twitter <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Twitter-logo.svg/2491px-Twitter-logo.svg.png" width="30"/></a>
<a href="https://snollygoster.xyz/" target="_blank">Visit my website <img src="https://raw.githubusercontent.com/dickydamaraa/explorer-1/master/public/logox.png" width="30"/></a>
</p>


<p align="center">
  <img height="100" height="auto" src="https://cdn.builder.io/api/v1/image/assets%2F580ff9284d33405f94bd899116dbdf56%2F1846b26b1cf2456bb5da6004e6629645?width=132">
</p>


# Planq node setup mainnet manual
If you want to setup node with manual method

### Set vars and port
```
export MONIKER=YOUR_MONIKER (Note ; without space or symbol for easier installation)
source ~/.bash_profile
```

### Update Packages and Depencies
```
sudo apt update && sudo apt upgrade-y
```

Install Depencies
```
sudo apt install curl tar wget tmux htop net-tools clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

### Install Golang
```
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
```

### Install Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```

### Download binaries
```
cd $HOME
rm -rf planq
git clone https://github.com/planq-network/planq.git
cd planq
git fetch
```
Build Binaries
```
git checkout v1.0.3
make install
mkdir -p $HOME/.planqd/cosmovisor/genesis/bin
mkdir -p ~/.planqd/cosmovisor/upgrades
cp ~/go/bin/planqd ~/.planqd/cosmovisor/genesis/bin
```
  
### Config
```
planqd config chain-id planq_7070-2
planqd config keyring-backend file
planqd config node tcp://localhost:14657
```

### Init 
```
planqd init $MONIKER --chain-id planq_7070-2
```

### Download genesis file and addrbook
```
wget https://raw.githubusercontent.com/planq-network/networks/main/mainnet/genesis.json
mv genesis.json ~/.planqd/config/
wget -O $HOME/.planqd/config/addrbook.json "http://addr.planq.snollygoster.xyz/addrbook.json"
```

### Set minimum gas price , seeds , and peers
```
SEEDS="dd2f0ceaa0b21491ecae17413b242d69916550ae@135.125.247.70:26656,0525de7e7640008d2a2e01d1a7f6456f28f3324c@51.79.142.6:26656,21432722b67540f6b366806dff295849738d7865@139.99.223.241:26656" 
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.planqd/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025aplanq\"|" $HOME/.planqd/config/app.toml
sed -i -e "s/^timeout_commit *=.*/timeout_commit = \"5s\"/" $HOME/.planqd/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 120/g' $HOME/.planqd/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 60/g' $HOME/.planqd/config/config.toml
```

### Pruning (Optional)
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.planqd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.planqd/config/app.toml
```

### Indexer (Optional)
```
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.planqd/config/config.toml
```

### Custom Port 
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:14658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:14657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"14660\"%" $HOME/.planqd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1417\"%; s%^address = \":8080\"%address = \":1480\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:1490\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:1491\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:1445\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:1446\"%" $HOME/.planqd/config/app.toml
```

### Create service file and start the node
```
sudo tee /etc/systemd/system/planqd.service > /dev/null <<EOF
[Unit]
Description=planqd
After=network-online.target

[Service]
User=$USER
ExecStart=$(which planqd)
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
sudo systemctl daemon-reload
sudo systemctl enable planqd
```
Start Planq
```
sudo systemctl restart planqd && sudo journalctl -u planqd -f -o cat
```

### After you finish and success with manual installation, you can continue on here (https://github.com/dickydamaraa/mainnet/blob/main/planq/readme.md#step-after-installation-automatic-or-manual) for the next step create wallet and validator.
