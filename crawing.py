import requests
from bs4 import BeautifulSoup
import json
import sys


argument = sys.argv
tday = argument[1]

ntos={}
ntos["01"]="January"
ntos["02"]="February"
ntos["03"]="March"
ntos["04"]="April"
ntos["05"]="May"
ntos["06"]="June"
ntos["07"]="July"
ntos["08"]="August"
ntos["09"]="September"
ntos["10"]="October"
ntos["11"]="November"
ntos["12"]="December"
l=tday.split("-")
year = l[0]
mon = ntos[l[1]]
day= str(int(l[2]))

def crawling_sites(url,tday):
    # 요청한 url을 html 문서 형식으로 받아오기
    response = requests.request('GET', url)
    soup = BeautifulSoup(response.content, 'html.parser')

    # 특정 태그의
    # 클래스 중심으로 찾고 싶을 때는 태그 바로 뒤에 '.클래스명'을 써주고,
    # id 중심으로 찾고 싶을 때는 태그 바로 뒤에 '#id명'을 써준다
    # 아래와 같이 쓴 경우에는 'rbj0Ud' 클래스명을 가진 div의 하위 div 태그를 가리킨다.
    titles = soup.select('div.current-events-content')
    g={}
    Date = tday
    g["date"] = Date;
    for x in titles:
        for s in x.contents:
            if str(s).startswith("<div") or str(s).startswith("<p><b>"):
                k=str(s.contents[0]).replace("<b>","")
                k=k.replace("</b>","")
                con = k
            if str(s).startswith("<ul"):
                text = str(s)
                text = text.replace("/wiki","https://en.wikipedia.org/wiki")
                g[con]=text
    return g


url = 'https://en.wikipedia.org/wiki/Portal:Current_events/'+year+"_"+mon+"_"+day
contents=crawling_sites(url,tday)
print(json.dumps(contents))

