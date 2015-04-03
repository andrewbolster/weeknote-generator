#!/usr/bin/ruby
#
# Weeknote - simple class to help generating weeknotes blog posts
# (c) Copyright 2013 Adrian McEwen
require 'pp'

class Weeknote
  attr_accessor :created_at, :html

  def initialize(created_at, html)
    @created_at = created_at
    @html = html
  end

  def Weeknote.new_from_tweet(tweet)
    # v5 of the Twitter gem won't let us change "text", so make a copy we can mod
    tweet_text = tweet.full_text.dup
    # Expand any URLs
    tweet.urls.each do |u|
      tweet_text.gsub!(u.url, "<a href=\"#{u.expanded_url}\">#{u.display_url}</a>")
    end
    # Expand any pictures
    tweet.media.each do |m|
      # FIXME This probably won't work when we get a non-picture media type
      if tweet_text.gsub!(m.url, "<a href=\"http://#{m.display_url}\">#{m.display_url}</a> <img src=\"#{m.media_url}\" width=\"#{m.sizes[:medium].w}\" height=\"#{m.sizes[:medium].h}\">") == nil
        # We didn't perform any substitution, so this will be one of the
	# additional images (that Twitter doesn't include in the text!)
	tweet_text = tweet_text + " <img src=\"#{m.media_url}\" width=\"#{m.sizes[:medium].w}\" height=\"#{m.sizes[:medium].h}\">"
      end
    end
    # Expand any twitter names, using friendly names rather than twitter handles
    tweet.user_mentions.each do |u|
      tweet_text.gsub!("@#{u.screen_name}", "<a href=\"http://twitter.com/#{u.screen_name}\">#{u.name}</a>")
    end
    html = "<li><a href=\"https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}\">#{tweet.user.name}</a>: #{tweet_text}</li>"
    # Expand any hashtags
    html.gsub!(/#(\w+)/) { "<a href=\"https://twitter.com/search?q=%23#{$1}\">##{$1}</a>" }
    Weeknote.new(tweet.created_at, html)
  end

  def Weeknote.new_from_irc(created_at, content)
    # HTML escape any <, > and &
    content.gsub!(/&/, "&amp;")
    content.gsub!(/>/, "&gt;")
    content.gsub!(/</, "&lt;")
    # Expand URLs
    content.gsub! /((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\-\w\/_\.]*(\?\S+)?)?)?)/, %Q{<a href="\\1">\\1</a>}
    Weeknote.new(created_at, "<li>"+content+"</li>")
  end
end

