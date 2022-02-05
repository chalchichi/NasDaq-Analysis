import schedule
import time
import Dbconnection
from datetime import datetime, timedelta
import pymysql
import FinanceDataReader as fdr
juso_db = pymysql.connect(
        user='oh',
        passwd='714257',
        host='localhost',
        db='StockDB',
        charset='utf8'
    )


TDAY = datetime.today().date() - timedelta(1)
ticker= 'TQQQ'
df = fdr.DataReader(ticker, TDAY- timedelta(20000), TDAY)

s=""
for i in range(df.shape[0]):
    Close = df.iloc[i]['Close']
    Open = df.iloc[i]['Open']
    High = df.iloc[i]['High']
    Low = df.iloc[i]['Low']
    Volume = df.iloc[i]['Volume']
    Variance = df.iloc[i]['Change']
    Day = df.iloc[i].name.strftime('%Y-%m-%d')
    n = '''('%s', '%s', '%s', '%s', '%s', '%s' , '%s')''' % (Day, Close, Open, High, Low, Volume, Variance)
    s += n + ","

s = s[:len(s)-1] +";"
sql = "INSERT INTO `%s` VALUES "%ticker + s


#커서 생성
cursor = juso_db.cursor(pymysql.cursors.DictCursor)

#테이블 생성
insert = "CREATE TABLE StockDB.%s (TDAY date NOT NULL,`Close` double NULL,High double NULL,`Open` double NULL,Low double NULL,Volume BIGINT UNSIGNED NULL,Variance double NULL,CONSTRAINT `PRIMARY` PRIMARY KEY (TDAY))" % ticker
insert+="\nENGINE=InnoDB"
insert+="\nDEFAULT CHARSET=utf8mb4"
insert+="\nCOLLATE=utf8mb4_0900_ai_ci"
insert+="\nCOMMENT='';"
cursor.execute(insert)
juso_db.commit()
print(insert)

#데이터 입력
cursor.execute(sql)
juso_db.commit()

#인덱스 생성
index1 = "CREATE INDEX %s_Close_OPEN_IDX USING BTREE ON StockDB.%s (`Close`,`Open`);"%(ticker,ticker)
cursor.execute(index1)
juso_db.commit()
print(index1)

index2 = "CREATE INDEX %s_High_LOW_IDX USING BTREE ON StockDB.%s (High,Low);"%(ticker,ticker)
cursor.execute(index2)
juso_db.commit()
print(index2)