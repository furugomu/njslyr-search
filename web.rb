#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require 'bundler'
Bundler.require
require 'sinatra'
require 'uri'

require './config'

set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')
set :haml, escape_html: true

get '/' do
  haml :index, locals: {records: nil, query: ''}
end

post '/' do
  redirect url_for(q: params[:q])
end

get '/:q/?:page?' do |query, page|
  query = URI.decode_www_form_component(query)
  records = Groonga[:Tweets].select do |record|
    record[:text] =~ query
  end
  page = records.paginate(
    [['_score', :desc], ['created', :desc]],
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

  def time(t)
    '<span title="%s">%s</span>' % [t.iso8601, t.strftime('%Y-%m-%d %H:%M:%S')]
  end
end

if __FILE__ == $0
  main
end
