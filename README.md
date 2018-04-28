# README

Application name: **GalleryVisitors**

Aim: Develop a web app to read visitors logs and process it to find inferences
 like _"Room 9, 50 minute average visit, 1 visitor(s) total"_ for every room of 
 museum in ascending order


Things you may want to cover:

* Ruby version: **ruby 2.4.1p111**

* Rails version: **Rails 5.1.6**

* How to run the app


    cd GalleryVisitors
  
    gem install bundler
  
    bundle install
  
    rails s
  

* How to run the test suite


    rake db:create RAILS_ENV=test
  
    rake db:migrate RAILS_ENV=test
  
    rails test test/models/log_parser_test.rb
  


* ...
