#!/bin/bash
/usr/bin/curl -H "Content-Type: application/json" --cacert /Users/nkacel/Workspace/dev/training/smart-elasticsearch-elk/crt/es01.crt -u elastic:changeme "$@"