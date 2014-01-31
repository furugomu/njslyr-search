#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require 'bundler'
Bundler.require
require 'uri'

require './config'

def main
  query = ARGV[0]
  unless query
    $stderr.puts 'usage: q.rb query'
    exit 1
  end

  tweets = Groonga['Tweets']
  records = tweets.select{|record| record['text'] =~ query }
  records.each do |record|
    puts record['togetter']['title']
    puts record['url']
    puts record['created']
    puts record['text']
    puts '---'
  end
  puts records.size
end

if __FILE__ == $0
  main
end
