./curl.sh -X GET https://localhost:9200/_search?pretty
./curl.sh -X GET https://localhost:9200/_cat/indices?v #list all indices.


./curl.sh -XPUT https://localhost:9200/movies -d '
{
    "mappings": {
        "properties": {
            "year": {
                "type": "date"
            }
        }
    }
}'

./curl.sh -XPUT https://localhost:9200/movies/_doc/109487?pretty -d '
{
    "genre": ["IMAX", "Sci-Fix"],
    "title": "Interstellar",
    "year": 2014
}'

./curl.sh -XGET https://localhost:9200/movies/_search?pretty

wget http://media.sundog-soft.com/es8/movies.json

#Insert many data at once
./curl.sh -XPUT https://localhost:9200/_bulk?pretty --data-binary @movies.json

#Updating the wall document with PUT command
./curl.sh -XPUT https://localhost:9200/movies/_doc/109487?pretty -d '
{
    "genre": ["IMAX", "Sci-Fix"],
    "title": "Interstellar foo",
    "year": 2014
}'

./curl.sh -XGET https://localhost:9200/movies/_doc/109487?pretty

#Partial Update with POST command
./curl.sh -XPOST https://localhost:9200/movies/_update/109487?pretty -d '
{   "doc": {
         "title": "Interstellar"
    }
}'

#Deleting document
./curl.sh -XGET https://localhost:9200/movies/_search?q=Dark
 
./curl.sh -XDELETE https://localhost:9200/movies/_doc/58559?pretty

#Exerice
./curl.sh -XPUT https://localhost:9200/movies/_doc/1988?pretty -d '
{
    "genre": ["IMAX", "Sci-Fix"],
    "title": "Nacim KACEL",
    "year": 2024
}'

./curl.sh -XPUT https://localhost:9200/movies/_doc/1988?pretty -d '
{
    "genre": ["IMAX", "Sci-Fix"],
    "title": "Smart Nacim KACEL",
    "year": 2024
}'

./curl.sh -XPOST https://localhost:9200/movies/_update/1988?pretty -d '
{   "doc": {
         "title": "Make Nacim Begger Again"
    }
}'
./curl.sh -XGET https://localhost:9200/movies/_doc/1988?pretty
./curl.sh -XDELETE https://localhost:9200/movies/_doc/1988 ?pretty

#24 - Delling with Concurrency
./curl.sh -XGET https://localhost:9200/movies/_search?pretty
./curl.sh -XGET https://localhost:9200/movies/_doc/109487?pretty

./curl.sh -XPUT "https://localhost:9200/movies/_doc/109487?if_seq_no=6&if_primary_term=2" -d '
{
    "genre": ["IMAX", "Sci-Fix"],
    "title": "Interstellar foo",
    "year": 2014
}'

# Elasticsearch will do it automaticlly for us
./curl.sh -XPOST https://localhost:9200/movies/_update/109487?retry_on_conflict=5 -d '
{   "doc": {
         "title": "Make Nacim Begger Again"
    }
}'

# 25 - Using Analyzer and Tokenizer
./curl.sh -XGET https://localhost:9200/movies/_search?pretty -d '
{   "query": {
        "match": {
            "title": "Start Trek"
        }
    }
}'

./curl.sh -XGET https://localhost:9200/movies/_search?pretty -d '
{   "query": {
        "match_phrase": {
            "genre": "Sci"
        }
    }
}'

./curl.sh -XDELETE https://localhost:9200/movies
# keyword : only exact world match.   
./curl.sh -XPUT https://localhost:9200/movies -d '
{
    "mappings": {
        "properties": {
            "id": {"type" : "integer" },
            "year": { "type" : "date" },
            "genre": {"type" : "keyword" },
            "title": {"type": "text", "analyzer" : "english"}
        }
    }
}'

./curl.sh -XPUT https://localhost:9200/_bulk?pretty --data-binary @movies.json
./curl.sh -XGET https://localhost:9200/movies/_search?pretty -d '
{   "query": {
        "match_phrase": {
            "genre": "Sci"
        }
    }
}'

./curl.sh -XGET https://localhost:9200/movies/_search?pretty -d '
{   "query": {
        "match": {
            "title": "star wars"
        }
    }
}'

#Data Modeling and Parent Child relationship
#franchise (parent) -> film (child) 
./curl.sh -XPUT https://localhost:9200/series -d '
{
    "mappings": {
        "properties": {
            "film_to_franchise": {
                "type": "join",
                "relations": {"franchise" : "film"}
            }
        }
    }
}'

wget http://media.sundog-soft.com/es8/series.json
./curl.sh -XPUT https://localhost:9200/_bulk?pretty --data-binary @series.json

./curl.sh -XGET https://localhost:9200/series/_search?pretty -d '
{   "query": {
        "has_parent": {
            "parent_type": "franchise",
            "query" : {
                "match" : {
                    "title": "star wars"
                }
            }
        }
    }
}'

./curl.sh -XGET https://localhost:9200/series/_search?pretty -d '
{   "query": {
        "has_child": {
            "type": "film",
            "query" : {
                "match" : {
                    "title": "The Force Awakens"
                }
            }
        }
    }
}'

#Flattened DataType

./curl.sh -XPUT https://localhost:9200/demo-default/_doc/1 -d '
{
  "message": "[5592:1:0309/123054.737712:ERROR:child_process_sandbox_support_impl_linux.cc(79)] FontService unique font name matching request did not receive a response.",
  "fileset": {
    "name": "syslog"
  },
  "process": {
    "name": "org.gnome.Shell.desktop",
    "pid": 3383
  },
  "@timestamp": "2020-03-09T18:00:54.000+05:30",
  "host": {
    "hostname": "bionic",
    "name": "bionic"
  }
}'
#Get dynamique mapping
./curl.sh -XGET "https://localhost:9200/demo-default/_mapping?pretty=true"
# Get cluster state
./curl.sh -XGET "https://127.0.0.1:9200/_cluster/state?pretty=true" >> es-cluster-state.json