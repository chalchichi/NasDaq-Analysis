import FinanceDataReader as fdr
import schedule
import time
import Dbconnection
from datetime import datetime, timedelta
import pymysql


def func():
    TDAY = datetime.today().date() - timedelta(1)
    df = fdr.DataReader('IXIC', TDAY, TDAY)
    if df.shape[0] == 0: return
    Close = df.iloc[0]['Close']
    Open = df.iloc[0]['Open']
    High = df.iloc[0]['High']
    Low = df.iloc[0]['Low']
    Variance = df.iloc[0]['Change']
    juso_db = pymysql.connect(
        user='oh',
        passwd='714257',
        host='localhost',
        db='StockDB',
        charset='utf8'
    )
    sql = '''INSERT INTO `NASDAQ` (Tday, Close, Open, High, Low,Variance) 
        VALUES ('%s', '%s', '%s', '%s','%s','%s');''' % (TDAY, Close, Open, High, Low, Variance)
    print(sql)
    cursor = juso_db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql)
    juso_db.commit()


def func2():
    juso_db = pymysql.connect(
        user='oh',
        passwd='714257',
        host='localhost',
        db='StockDB',
        charset='utf8'
    )
    cursor = juso_db.cursor(pymysql.cursors.DictCursor)

    getlist = "SELECT * FROM `Tickers`;"
    cursor.execute(getlist)
    result = cursor.fetchall()
    tickerlist = []

    for t in result:
        tickerlist.append(t['Name'])

    for ticker in tickerlist:
        TDAY = datetime.today().date() - timedelta(1)
        df = fdr.DataReader(ticker, TDAY, TDAY)
        if df.shape[0] == 0: return
        Close = df.iloc[0]['Close']
        Open = df.iloc[0]['Open']
        High = df.iloc[0]['High']
        Low = df.iloc[0]['Low']
        Variance = df.iloc[0]['Change']
        Volume = df.iloc[0]['Volume']

        sql = '''INSERT INTO `%s` (Tday, Close, Open, High, Low,Volume,Variance) 
            VALUES ('%s', '%s', '%s', '%s','%s','%s','%s');''' % (
            ticker, TDAY, Close, Open, High, Low, Volume, Variance)
        print(sql)

        cursor.execute(sql)
        juso_db.commit()


schedule.every().day.at("07:00").do(func)
schedule.every().day.at("07:00").do(func2)
while True:
    schedule.run_pending()
