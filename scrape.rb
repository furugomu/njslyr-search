#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

require 'bundler'
Bundler.require
require 'uri'

require './config'

def main
  urls = %w(
    http://togetter.com/li/273636
    http://togetter.com/li/273650
    http://togetter.com/li/273674
    http://togetter.com/li/274968
    http://togetter.com/li/320805
    http://togetter.com/li/441427
    http://togetter.com/li/585643
  )
  urls.each do |url|
    scrape_matome(url)
  end
end

# iPhone のふりをして GET でアクセス
def get(url)
  Faraday.get(url) do |req|
    req.headers['User-Agent'] = 'Mozilla/5.0 (iPhone OS 7_0_2)'
  end
end

# エピソードまとめを
def scrape_matome(url='http://togetter.com/li/273636')
  togetter_each_page(url) do |doc|
    doc.css('.type_rich a[href], .type_togetter a[href]').each do |link|
      url = link[:href]
      url =~ %r(^http://togetter\.com/li/) or next
      p url
      scrape(url)
    end
  end
end

def togetter_each_page(url)
  loop do
    doc = Nokogiri::HTML(get(url).body)
    yield doc
    link = doc.at('[href][rel=next]') or break
    url = URI.join(url, link[:href]).to_s
  end
end

# ページを辿ってぜんぶアレする
def scrape(togetter_url)
  return if Groonga[:Togetters].select{|r|r.url==togetter_url}.size > 0

  togetter = nil
  togetter_each_page(togetter_url) do |doc|
    unless togetter
      title = doc.at('title').text.sub(' - Togetterまとめ', '')
      togetter = Groonga['Togetters'].add({
        title: title,
        url: togetter_url,
      })
      # 実況つきのは省略
      title =~ /【実況】/ and return
    end
    scrape_page(doc, togetter)
  end
  sleep 1
end

# 1ページ分のツイットをアレする
# @return [{}]
def scrape_page(doc, togetter)
  tweets = Groonga['Tweets']
  doc.css('.type_tweet').each do |tweet|
    text = tweet.at('.tweet').text
    link = tweet.css('.status_right a[href]').last
    time = Time.parse(link.text+' +0900')
    url = link[:href]

    # とりあえず njslyr アカウント以外のツイートは使わない
    url =~ %r{/njslyr/} or next

    tweets.add({
      text: text,
      url: url,
      created: time,
      togetter: togetter,
    })
  end
end

if __FILE__ == $0
  main
end
