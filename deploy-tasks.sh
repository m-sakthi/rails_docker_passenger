#!/bin/bash
cd /opt/dockerrailsdemo
export HOME=/root
bundle exec rake db:migrate tmp:create
