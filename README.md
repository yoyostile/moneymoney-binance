# moneymoney-binance

Fetches balances from Binance.com API and returns them as securities. 
Prices in EUR from cryptocompare.com.

Requirements:
* MoneyMoney v2.3.4

## Extension Setup

You can get a signed version of this extension from

* the `dist` directory in this repository

Once downloaded, move `binance.lua` to your MoneyMoney Extensions folder.

## Account Setup

### Binance

1. Log in to your Binance account
2. Go to [User center -> Create API Key](https://www.binance.com/userCenter/createApi.html)
3. Create new API key with "Read Info" permissions

### MoneyMoney

Add a new account (type "Binance Account") and use your Binance API key as username and your Binance API secret as password.

## Screenshots

![MoneyMoney screenshot with Coinbase balances](https://s3.r4r3.me/random/moneymoney-binance.png)
