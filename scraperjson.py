from bs4 import BeautifulSoup
import requests
from multiprocessing import Pool
import requests
import os
from urllib import url2pathname
from multiprocessing.dummy import Pool as ThreadPool
import numpy as np
import csv

class LocalFileAdapter(requests.adapters.BaseAdapter):
    """Protocol Adapter to allow Requests to GET file:// URLs

    @todo: Properly handle non-empty hostname portions.
    """

    @staticmethod
    def _chkpath(method, path):
        """Return an HTTP status for the given filesystem path."""
        if method.lower() in ('put', 'delete'):
            return 501, "Not Implemented"  # TODO
        elif method.lower() not in ('get', 'head'):
            return 405, "Method Not Allowed"
        elif os.path.isdir(path):
            return 400, "Path Not A File"
        elif not os.path.isfile(path):
            return 404, "File Not Found"
        elif not os.access(path, os.R_OK):
            return 403, "Access Denied"
        else:
            return 200, "OK"

    def send(self, req, **kwargs):  # pylint: disable=unused-argument
        """Return the file specified by the given request

        @type req: C{PreparedRequest}
        @todo: Should I bother filling `response.headers` and processing
               If-Modified-Since and friends using `os.stat`?
        """
        path = os.path.normcase(os.path.normpath(url2pathname(req.path_url)))
        response = requests.Response()

        response.status_code, response.reason = self._chkpath(req.method, path)
        if response.status_code == 200 and req.method.lower() != 'head':
            try:
                response.raw = open(path, 'rb')
            except (OSError, IOError), err:
                response.status_code = 500
                response.reason = str(err)

        if isinstance(req.url, bytes):
            response.url = req.url.decode('utf-8')
        else:
            response.url = req.url

        response.request = req
        response.connection = self

        return response

    def close(self):
        pass

hero_number=30

requests_session = requests.session()
requests_session.mount('file://', LocalFileAdapter())

#print 'Requesting hero list and matchup links...'
matchup_links = {}
#print requests_session.get("file:///home/erick/Dropbox/erick/dotaproj/postpycon/dotabuff_heroes.html")
heroes_html = BeautifulSoup(requests_session.get('file:///home/erick/Dropbox/erick/dotaproj/postpycon/dotabuff_heroes.html').text,'lxml')
#print heroes_html.findAll("a")
#test= heroes_html.find('div',{ "class" : "hero-grid" })
#print test
#print test[0]
i=0;
for a in heroes_html.find('div','hero-grid').find_all('a'):
	matchup_links[a.text] = 'file:///home/erick/Dropbox/erick/dotaproj/postpycon/heropages/'+a.text.rstrip()
	i=i+1
	if i>=30:
		break
	
print 'Done.'

print 'Fetching matchup data for %s heroes...' % len(matchup_links)
pool = ThreadPool(1)
responses = pool.map(requests_session.get, matchup_links.values())
all_html = [response.text for response in responses]
print 'Done.'


def process_matchup_html(html):
	soup = BeautifulSoup(html, "lxml")
	hero_name = soup.find('title').text.split(' - ')[0]
	rows = soup.find('tbody').find_all('tr')
	#print "number of rows for ",hero_name,"= ",len(rows)
	matchups = {}
	for row in rows:
		cells = row.find_all('td')
		name = cells[1].text
		advantage = cells[2].text.strip('%')
		matchups[name] = advantage
		#print matchups
	return (hero_name, matchups)
print 'Processing %s matchups...' % len(matchup_links)
pool = ThreadPool(1)
matchups_list = pool.map(process_matchup_html, all_html)
heroes=[]
for i in range(len(matchups_list)):
	heroes.append(matchups_list[i][0]);
	print "\"",matchups_list[i][0],"\"",","
#print heroes

matchups = {matchup[0]: matchup[1] for matchup in matchups_list}
matrix=np.zeros((len(heroes),len(heroes)))
for i in range(len(heroes)):
	for j in range(len(heroes)):
		if i!=j:
			matrix[i][j]=matchups[heroes[i]][heroes[j]]
print matrix
np.savetxt("advantages_30.csv", matrix, delimiter=",",fmt='%.3f')
print 'Done.'
hero_one = 'Bloodseeker'
hero_two = 'Ancient Apparition'

print '%s has a %s%% advantage over %s.' % (hero_one, matchups[hero_one][hero_two], hero_two)




