-- Inofficial Binance Extension (www.binance.com) for MoneyMoney
-- Fetches balances from Binance API and returns them as securities
--
-- Username: Binance API Key
-- Password: Binance API Secret
--
-- Copyright (c) 2017 Johannes Heck
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking {
  version     = 1.1,
  url         = "https://api.binance.com/api",
  description = "Fetch balances from Binance API and list them as securities",
  services    = { "Binance Account" },
}

local apiKey
local apiSecret
local balances
local currency

local currencySymbols = {
  BCC = "BCH",
  IOTA = "IOT"
}

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Binance Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  apiKey = username
  apiSecret = password
  currency = "EUR"
end

function ListAccounts (knownAccounts)
  local account = {
    name = market,
    accountNumber = "Binance Account",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  balances = queryPrivate("account")["balances"]
  local eurPrices = queryCryptoCompare("pricemulti", "?fsyms=" .. assetPrices() .. "&tsyms=EUR")

  local s = {}
  for key, value in pairs(balances) do
    if tonumber(value["free"]) > 0 then
      s[#s+1] = {
        name = value["asset"],
        market = market,
        currency = nil,
        quantity = value["free"],
        price = eurPrices[symbolForAsset(value["asset"])]["EUR"],
      }
    end
  end

  return {securities = s}
end

function symbolForAsset(asset)
  return currencySymbols[asset] or asset
end

function assetPrices()
  local assets = ""
  for key, value in pairs(balances) do
    if tonumber(value["free"]) > 0 then
      assets = assets .. symbolForAsset(value["asset"]) .. ','
    end
  end
  return assets
end

function EndSession ()
end

function bin2hex(s)
 return (s:gsub(".", function (byte)
   return string.format("%02x", string.byte(byte))
 end))
end

function queryPrivate(method)
  local path = string.format("/%s/%s", "v3", method)
  local timestamp = string.format("%d", MM.time() * 1000)
  local params = "timestamp=" .. timestamp
  local apiSign = MM.hmac256(apiSecret, params)

  local headers = {}
  headers["X-MBX-APIKEY"] = apiKey

  connection = Connection()
  content = connection:request("GET", url .. path .. "?" .. params .. "&signature=" .. bin2hex(apiSign), nil, nil, headers)

  json = JSON(content)

  return json:dictionary()
end

function queryCryptoCompare(method, query)
  local path = string.format("/%s/%s", "data", method)

  connection = Connection()
  content = connection:request("GET", "https://min-api.cryptocompare.com" .. path .. query)
  json = JSON(content)

  return json:dictionary()
end

-- SIGNATURE: MCwCFFPlEyxfzw2fxiU240wSJHRME7k7AhRf4QWm8QyjP4thFIBeFLpkgITHaw==
