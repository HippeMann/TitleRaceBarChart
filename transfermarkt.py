import re
import csv
import time
import requests
import unidecode

from bs4 import BeautifulSoup

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'}

data = {}

"""
data = {matchday: ranking}

data = {
1: [['1', 'Bor. Dortmund', '1', '1', '0', '0', '4', '1', '3', '3'], 
	['2', 'Bayern Munchen', '1', '1', '0', '0', '3', '1', '2', '3'], 
	['3', 'E. Frankfurt', '1', '1', '0', '0', '2', '0', '2', '3'], 
	['4', "Bor. M'gladbach", '1', '1', '0', '0', '2', '0', '2', '3'], 
	['5', 'FC Augsburg', '1', '1', '0', '0', '2', '1', '1', '3'], 
	['6', 'VfL Wolfsburg', '1', '1', '0', '0', '2', '1', '1', '3'], 
	['7', 'Hertha BSC', '1', '1', '0', '0', '1', '0', '1', '3'], 
	['8', '1.FSV Mainz 05', '1', '1', '0', '0', '1', '0', '1', '3'], 
	['9', 'Werder Bremen', '1', '0', '1', '0', '1', '1', '0', '1'], 
	['10', 'Hannover 96', '1', '0', '1', '0', '1', '1', '0', '1'], 
	['11', 'FC Schalke 04', '1', '0', '0', '1', '1', '2', '-1', '0'], 
	['12', 'F. Dusseldorf', '1', '0', '0', '1', '1', '2', '-1', '0'], 
	['13', 'VfB Stuttgart', '1', '0', '0', '1', '0', '1', '-1', '0'], 
	['14', '1.FC Nurnberg', '1', '0', '0', '1', '0', '1', '-1', '0'], 
	['15', 'TSG Hoffenheim', '1', '0', '0', '1', '1', '3', '-2', '0'], 
	['16', 'Bay. Leverkusen', '1', '0', '0', '1', '0', '2', '-2', '0'], 
	['17', 'SC Fribourg', '1', '0', '0', '1', '0', '2', '-2', '0'], 
	['18', 'RB Leipzig', '1', '0', '0', '1', '1', '4', '-3', '0']
   ], 
2: [['1', 'Bayern Munchen', '2', '2', '0', '0', '6', '1', '5', '6'], 
	['2', 'VfL Wolfsburg', '2', '2', '0', '0', '5', '2', '3', '6'], 
	['3', 'Hertha BSC', '2', '2', '0', '0', '3', '0', '3', '6'], 
	['4', 'Bor. Dortmund', '2', '1', '1', '0', '4', '1', '3', '4'], 
	['5', "Bor. M'gladbach", '2', '1', '1', '0', '3', '1', '2', '4']
.
.
.
.

"""

# read the competition
with open('comp.txt', 'r') as f:
	comp = f.read().strip()
print(comp)

url  = f"https://www.transfermarkt.com/_/spieltagtabelle/wettbewerb/{comp}"
soup = BeautifulSoup(requests.get(url, headers=headers).text, 'lxml')

print(url)

max_matchday = len(soup.find('select', {'name':"spieltag"}).findAll('option'))

meta_name = soup.find('meta', {'name':"keywords"})['content']
competition = meta_name.split(',')[0]
country = meta_name.split(',')[1]

print(country)
print(competition)

for matchday in range(1, max_matchday + 1):
	print(matchday, end=' ')
	time.sleep(1)
	url  = f"https://www.transfermarkt.fr/_/spieltagtabelle/wettbewerb/{comp}?saison_id=2018&spieltag={matchday}"
	soup = BeautifulSoup(requests.get(url, headers=headers).text, 'lxml')

	matchday_data = []
	table = soup.findAll('div', {'class':'box'})[3]
	table_body = table.find('tbody')
	rows = table_body.find_all('tr')
	for row in rows:
		row_values = []
		cells = [cell.text.strip() for cell in row.find_all('td')]
		for cell in cells: #"GF:GA" -> [..., GF, GA, ...]
			if ':' in cell: 
				row_values.append(cell.split(':')[0])
				row_values.append(cell.split(':')[1])
			elif cell:
				row_values.append(unidecode.unidecode(cell))

		matchday_data.append(row_values)

	data[matchday] = matchday_data

#Export data
path = f'Results/{country}-{competition}.csv'
print(f'\n{path}')

with open(path, 'w',  newline='', encoding='utf-8') as f:
	writer = csv.writer(f)
	for matchday, ranking in data.items():
		for line in ranking:
			writer.writerow([matchday] + line) #each line starts with the matchday number
