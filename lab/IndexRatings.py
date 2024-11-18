import csv
from collections import deque
from elasticsearch import Elasticsearch
from elasticsearch import helpers

def readMovies():
    csvfile = open('ml-latest-small/movies.csv', 'r', encoding="utf8")

    reader = csv.DictReader( csvfile )

    titleLookup = {}

    for movie in reader:
            titleLookup[movie['movieId']] = movie['title']

    return titleLookup

def readRatings():
    csvfile = open('ml-latest-small/ratings.csv', 'r', encoding="utf8")

    titleLookup = readMovies()

    reader = csv.DictReader( csvfile )
    for line in reader:
        rating = {}
        rating['user_id'] = int(line['userId'])
        rating['movie_id'] = int(line['movieId'])
        rating['title'] = titleLookup[line['movieId']]
        rating['rating'] = float(line['rating'])
        rating['timestamp'] = int(line['timestamp'])
        yield rating

ELASTIC_PASSWORD = "changeme"

es = Elasticsearch(
    "https://localhost:9200",
    ca_certs="/Users/nkacel/Workspace/dev/training/smart-elasticsearch-elk/crt/es01.crt",
    basic_auth=("elastic", ELASTIC_PASSWORD),
)

es.info()

es.indices.delete(index="ratings",ignore=404)
deque(helpers.parallel_bulk(es,readRatings(),index="ratings", request_timeout=300), maxlen=0)
es.indices.refresh()
