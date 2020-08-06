#! /bin/bash

echo "Starting nginx server"
/opt/nginx/sbin/nginx && \
echo "Starting rails server"
rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0
