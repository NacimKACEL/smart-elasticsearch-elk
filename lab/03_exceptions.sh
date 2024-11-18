# 29 Dealing with Mapping Exceptions

./curl.sh --request PUT 'https://localhost:9200/microservice-logs' \
--data-raw '{
   "mappings": {
       "properties": {
           "timestamp": { "type": "date"  },
           "service": { "type": "keyword" },
           "host_ip": { "type": "ip" },
           "port": { "type": "integer" },
           "message": { "type": "text" }
       }
   }
}'

./curl.sh --request POST 'https://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "ABC", "host_ip": "10.0.2.15", "port": 12345, "message": "Started!" }'

./curl.sh -XGET https://localhost:9200/microservice-logs/_search?pretty

./curl.sh --request POST 'https://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "XYZ", "host_ip": "10.0.2.15", "port": "15000", "message": "Hello!" }'


./curl.sh --request POST 'https://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "XYZ", "host_ip": "10.0.2.15", "port": "NONE", "message": "I am not well!" }'


# Close index
./curl.sh --request POST 'https://localhost:9200/microservice-logs/_close'
 
# Set Mappings
./curl.sh --location --request PUT 'https://localhost:9200/microservice-logs/_settings' \
--data-raw '{
   "index.mapping.ignore_malformed": true
}'
 
# Open index
./curl.sh --request POST 'https://localhost:9200/microservice-logs/_open'


./curl.sh --request POST 'http://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "XYZ", "host_ip": "10.0.2.15", "port": "NONE", "message": "I am not well!" }'

# How if message become json object => exception Can't get text on a START_OBJECT at 1:111
./curl.sh --request POST 'https://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "ABC", "host_ip": "10.0.2.15", "port": 12345, "message": {"data": {"received":"here"}}}'
# Add pyaload object
./curl.sh --request POST 'https://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "ABC", "host_ip": "10.0.2.15", "port": 12345, "message": "Received...", "payload": {"data": {"received":"here"}}}'

# How to solve that mecanic mappings ? establish shared guidelines => dead letter queue pattern that would store the fail documents  
./curl.sh --request POST 'https://localhost:9200/microservice-logs/_doc?pretty' \
--data-raw '{"timestamp": "2020-04-11T12:34:56.789Z", "service": "ABC", "host_ip": "10.0.2.15", "port": 12345, "message": "Received...", "payload": {"data": {"received": {"even": "more"}}}}'

# Number 1000, which is the default limit of the number of fields in a mapping
thousandone_fields_json=$(echo {1.. 1001.. 1} | jq -Rn '( input | split(" ") ) as $nums | $nums[] | . as $key | [{key:($key|tostring),value:($key|tonumber)}] | from_entries' | jq -cs 'add')
 
echo "$thousandone_fields_json"

./curl.sh --request POST 'http://localhost:9200/big-objects/_doc?pretty' \
--data-raw "$thousandone_fields_json"

#But it's verry dangerous fro production performance
./curl.sh --location --request PUT 'http://localhost:9200/big-objects/_settings' \
--data-raw '{
"index-mapping-total fields.limit": 1001"
}'

