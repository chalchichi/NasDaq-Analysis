import yfinance as yf

import json
import sys

argument = sys.argv
ticker = "AAPL"


def getinfo(ticker):
    data = yf.Ticker(ticker)
    info =  data.get_info()
    g["CompanyName"] = info["longName"]
    g["sector"] = info["sector"]
    g["city"] = info["city"]
    g["country"] = info["country"]
    g["website"] = info["website"]
    g["fullTimeEmployees"] = info['fullTimeEmployees']
    g['freeCashflow'] = info['freeCashflow']
    g['earningsGrowth'] = info['earningsGrowth']
    g['returnOnAssets'] = info['returnOnAssets']
    g['totalCash'] = info['totalCash']
    g['totalDebt'] = info['totalDebt']
    g['52WeekChange'] = info['52WeekChange']
    g['shortRatio'] = info['shortRatio']
    return g


res = getinfo(ticker)
print(json.dumps(res))
