#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require 'bundler'
Bundler.require
require 'sinatra'
require 'uri'

require './config'

get '/' do
  haml :index, locals: {records: nil, query: ''}
end

post '/' do
  redirect to('/%s' % URI.encode_www_form_component(params[:q].to_s))
end

get '/:q/?:page?' do |query, page|
  query = URI.decode_www_form_component(query)
  records = Groonga[:Tweets].select do |record|
    record[:text] =~ query
  end
  page = records.paginate(
    [['created', :desc]],
    page: (page||1).to_i,
    size: 50)
  haml :index, locals: {records: page, query: query}
end

helpers do
  def url_for(params)
    path = '/'
    if params[:q]
      path << URI.encode_www_form_component(params[:q].to_s)
      path << '/'+params[:page].to_i.to_s if params[:page]
    end
    url(path)
  end

  def paginate(records)
    haml :_paginate, locals: {records: records}
  end
end

if __FILE__ == $0
  main
end
