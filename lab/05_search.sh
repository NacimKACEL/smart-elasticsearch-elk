./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "match": { "title": "intersteller"}
    }
}'

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "fuzzy": { 
            "title": {
                "value": "intersteller", "fuzziness" : 1
            }
        }
    }
}'

# Partial matching
./curl.sh -XDELETE https://localhost:9200/movies
./curl.sh -XPUT https://localhost:9200/movies -d '
{
    "mappings": {
        "properties": {
            "year": { "type" : "text" }
        }
    }
}'
./curl.sh -XPUT 'https://localhost:9200/_bulk?pretty' --data-binary @movies.json
#reg ex
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "wildcard": { 
            "year": "1*"
        }
    }
}'
# prefix
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "prefix": { 
            "year": "1"
        }
    }
}'
# search as google , 
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "match_phrase_prefix": { 
            "title" : {
                "query" : "star t",
                "slop" : 10
            }
        }
    }
}'

# More perfs with ngrame notion
./curl.sh -XDELETE https://localhost:9200/movies
./curl.sh -XPUT https://localhost:9200/movies -d '
{
    "settings": {
        "analysis": {
            "filter" : {
                "autocomplete_filter" : {
                    "type": "edge_ngram",
                    "min_gram": 1,
                    "max_gram": 20
                }
            },
            "analyzer": {
                "autocomplete": {
                    "type": "custom",
                    "tokenizer": "standard",
                    "filter": [
                        "lowercase",
                        "autocomplete_filter" 
                    ]
                }
            }
        }
    }
}'

#check the analyzer
./curl.sh -XGET "https://127.0.0.1:9200/movies/_analyze?pretty" -d '
{
    "analyzer": "autocomplete",
    "text": "sta"
}'

#apply the analyzer to title
./curl.sh -XPUT 'https://localhost:9200/movies/_mapping?pretty' -d '
{
    "properties": {
        "title": {
            "type": "text",
            "analyzer": "autocomplete"
        }
    }
}'
#import and index data 
./curl.sh -XPUT 'https://localhost:9200/_bulk?pretty' --data-binary @movies.json

#Try it out
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "match": { 
            "title": {
                "query": "sta"
            }
        }
    }
}'

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
         "match": { 
            "title": {
                "query": "sta",
                "analyzer": "standard" 
            }
        }
    }
}'





