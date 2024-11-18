#Importing via script/json
wget https://files.grouplens.org/datasets/movielens/ml-latest-small.zip
wget media.sundog-soft.com/es8/MoviesToJson.py
python3 MoviesToJson.py >> moremovies.json

./curl.sh -XDELETE https://localhost:9200/movies
./curl.sh -XPUT 'https://localhost:9200/_bulk?pretty' --data-binary @moremovies.json
./curl.sh -XGET "https://127.0.0.1:9200/movies/_search?q=title=star&pretty"

 
 #Importing with Client librairies
 pip3 install elasticsearch
 wget media.sundog-soft.com/es8/IndexRatings.py 
