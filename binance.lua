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
  version     = 1.0,
  url         = "https://api.binance.com/api",
  description = "Fetch balances from Binance API and list them as securities",
  services    = { "Binance Account" },
}

local apiKey
local apiSecret
local currency
local balances
local prices
local apiUrlVersion = "v1"

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
  local s = {}
  local balances = queryPrivate("account")["balances"]
  local assets = ""
  for key, value in pairs(balances) do
    if value["free"] ~= "0.00000000" then
      assets = assets .. value["asset"] .. ','
    end
  end
  local eurPrice = queryCryptoCompare("pricemulti", "?fsyms=" .. assets .. "&tsyms=EUR")

  for key, value in pairs(balances) do
    if value["free"] ~= "0.00000000" then
      s[#s+1] = {
        name = value["asset"],
        market = market,
        currency = nil,
        quantity = value["free"],
        price = eurPrice[value["asset"]]["EUR"],
      }
    end
  end

  return {securities = s}
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