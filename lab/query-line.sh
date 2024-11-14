# Query Line search
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?q=title=star&pretty"

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?q=+year:>2016+title=trek&pretty"

#Query vs Filter
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query": {
        "match" : {
            "title": "star" 
        }
    }
}'

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query": {
        "bool" : {
            "must" : { "term" : { "title": "trek"}},
            "filter" : { "range" : { "year" : { "gte": 2010}}}
        }
    }
}'

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query": {
        "match" : {
            "title": "star wars" 
        }
    }
}'

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query": {
        "match_phrase" : {
            "title": "star wars" 
        }
    }
}'

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query": {
        "match_phrase" : {
            "title": {"query": "star beyond", "slop": 1}
        }
    }
}'

# Pagination 
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?size=2&from=2&pretty" 

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "from": 2,
    "size": 2,
    "query": {
        "match" : { "genre": "Sci-Fi"}
    }
}'

# Sorting
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?sort=year&pretty"

# sort text field error !  
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?sort=title&pretty"

# Solution 
./curl.sh -XDELETE https://localhost:9200/movies

./curl.sh -XPUT https://localhost:9200/movies -d '
{
    "mappings": {
        "properties": {
            "title": {
                "type": "text", 
                "fields" : {
                    "raw": {
                        "type" : "keyword"
                    }
                }
            }
        }
    }
}'

./curl.sh -XPUT https://localhost:9200/_bulk?pretty --data-binary @movies.json

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?sort=title.raw&pretty"
            

./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?pretty" -d '
{
    "query" : {
        "bool" : {
            "must" : { "match": { "genre": "Sci-Fi"}},
            "must_not" : { "match": { "title" : "trek"}},
            "filter": { 
                "range": {
                    "year": {
                        "gte": 201O,
                        "lt": 2015
                    }
                }
            }
        }
    }
}'

