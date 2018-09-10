#!/bin/bash

# bundle exec rake db:drop  
# bundle exec rake db:create db:migrate db:seed
bundle exec rake db:migrate

bundle check || bundle install

bundle exec puma -C config/puma.rb
