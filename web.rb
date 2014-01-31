#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require 'bundler'
Bundler.require
require 'sinatra'
require 'uri'

require './config'

get '/' do
  haml :index, locals: {records: [], query: ''}
end

post '/' do
  redirect to('/%s' % URI.encode_www_form_component(params[:q].to_s))
end

get '/:query' do |query|
  query = URI.decode_www_form_component(query)
  records = Groonga[:Tweets].select do |record|
    record[:text] =~ query
  end
  haml :index, locals: {records: records, query: query}
end

if __FILE__ == $0
  main
end
