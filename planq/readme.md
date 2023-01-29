<p style="font-size:14px" align="right">
<a href="https://t.me/dickydamara" target="_blank">Contact me on Telegram <img src="https://user-images.githubusercontent.com/50621007/183283867-56b4d69f-bc6e-4939-b00a-72aa019d1aea.png" width="30"/></a>
<a href="https://discordapp.com/users/392347017818669056" target="_blank">Contact me on Discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://twitter.com/snollyygoster" target="_blank">Contact me on twitter <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Twitter-logo.svg/2491px-Twitter-logo.svg.png" width="30"/></a>
<a href="https://snollygoster.xyz/" target="_blank">Visit my website <img src="https://raw.githubusercontent.com/dickydamaraa/explorer-1/master/public/logox.png" width="30"/></a>
</p>


<p align="center">
  <img height="100" height="auto" src="https://cdn.builder.io/api/v1/image/assets%2F580ff9284d33405f94bd899116dbdf56%2F1846b26b1cf2456bb5da6004e6629645?width=132">
</p>


# Planq node setup mainnet
Official documentation:
- Explorer: https://explorer.planq.network/planq_7070-2/staking
- Github: https://github.com/planq-network/planq
- Discord: https://discord.gg/planq-network
- Docs planq network : https://docs.planq.network/

## Hardware requirements
Same with any cosmos-SDK chain, check this out!

Minimum Hardware Requirements : \
• 3x CPUs; the faster clock speed the better \
• 4GB RAM \
• 80GB Disk \
• Permanent Internet connection (traffic will be minimal during run node; 10Mbps will be plenty - for production at least 100Mbps is expected)


Recommended Hardware Requirements : \
• 4x CPUs; the faster clock speed the better \
• 8GB RAM \
• 200GB of storage (SSD or NVME) \
• Permanent Internet connection (traffic will be minimal during run node; 10Mbps will be plenty - for production at least 100Mbps is expected)

**Thats requirements if you want run with local device, but my advice it will great if you rent a VPS and your server will online 24x7**

## Node setup
### • Automatic Installation •
You can setup your mainnet node in few minutes with this script below. Just follow the instructions.\
Note : **I prefer on manual, so you can learn new experience to solve problem :) **
```
wget -O autoplanq.sh https://raw.githubusercontent.com/dickydamaraa/mainnet/main/planq/auto_planq.sh && chmod +x autoplanq.sh && ./autoplanq.sh
```
### • Manual Installation •
You can follow manual guide on here > (https://github.com/dickydamaraa/mainnet/blob/main/planq/manual_planq.md) if you try new experience and better prefer setting up node with manually

============================================================================================
## Step after installation automatic OR manual
### Create wallet
To create new wallet
```
planqd keys add wallet
```
Change `wallet` to name own your wallet

To recover wallet existing keys with mneomenic 
```
planqd keys add wallet --recover
```
Change `wallet` to name own your wallet

To see current keys 
```
planqd keys list
```

### Create validator
Make sure your node was synced to false status, create validator

To check if your node is synced simply run
`curl http://localhost:14657/status sync_info "catching_up": false`

Creating validator with `10 Planq` change the value as you like

```
planqd tx staking create-validator \
  --amount 10000000000000000000aplanq \
  --from wallet \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1000000" \
  --pubkey $(planqd tendermint show-validator) \
  --moniker $MONIKER \
  --chain-id planq_7070-2 \
  --identity=  \
  --website="" \
  --details=" " \
  --gas="1000000" \
  --gas-prices="30000000000aplanq" \
  --gas-adjustment="1.15" \
  -y
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu planqd -o cat
```

Start service
```
sudo systemctl start planqd
```

Stop service
```
sudo systemctl stop planqd
```

Restart service
```
sudo systemctl restart planqd
```

### Node info
Synchronization info
```
planqd status 2>&1 | jq .SyncInfo
```

Validator info
```
planqd status 2>&1 | jq .ValidatorInfo
```

Node info
```
planqd status 2>&1 | jq .NodeInfo
```

Show node id
```
planqd tendermint show-node-id
```

### Wallet operations
List all wallets
```
planqd keys list
```

Recover your wallet with phrase
```
planqd keys add wallet --recover
```

Delete your wallet
```
planqd keys delete wallet
```

Check your wallet balance
```
planqd query bank balances <address>
```

Transfer funds
```
planqd tx bank send <FROM ADDRESS> <TO_planq_WALLET_ADDRESS> 10000000aplanq
```

### Voting
```
planqd tx gov vote 1 yes --from wallet --chain-id=planq_7070-2
```

### Staking, Delegation and Rewards
Delegate stake
```
planqd tx staking delegate <planq valoper> 10000000aplanq --from=wallet --chain-id=planq_7070-2 --gas=auto
```

Redelegate stake from validator to another validator
```
planqd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000aplanq --from=wallet --chain-id=planq_7070-2 --gas=auto
```

Withdraw all rewards
```
planqd tx distribution withdraw-all-rewards --from=wallet --chain-id=planq_7070-2 --gas=auto
```

Withdraw rewards with commision
```
planqd tx distribution withdraw-rewards <planq valoper> --from=wallet --commission --chain-id=planq_7070-2
```

### Validator management
Edit validator
```
planqd tx staking edit-validator \
  --moniker=$MONIKER \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=planq_7070-2 \
  --from=wallet
```

Unjail validator
```
planqd tx slashing unjail \
  --broadcast-mode=block \
  --from=wallet \
  --chain-id=planq_7070-2 \
  --gas=auto
```

### Delete node
```
sudo systemctl stop planqd && \
sudo systemctl disable planqd && \
rm /etc/systemd/system/planqd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .planqd && \
rm -rf $(which planqd)
```

