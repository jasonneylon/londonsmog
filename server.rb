# encoding: UTF-8
# Encoding.default_internal = Encoding.default_external = 'UTF-8'

require "bundler/setup"
require "sinatra"
require 'sinatra/contrib'
require "haml"
require "sass"
require "sinatra/reloader" if development?
require 'net/http'
require 'rexml/document'
require "sass/plugin/rack"

require File.join(File.dirname(__FILE__), *%w[lib helpers])

include Helpers

configure do
  set :haml, { :attr_wrapper => '"', :format => :html5 }

 Sass::Plugin.compiler.add_template_location("./public/sass")
 use Sass::Plugin::Rack
 
end


get "/" do
	url = "http://www.londonair.org.uk/london/rss/rssLaGroupXml.asp?lagroup=LAQNiPhone"

	xml_data = Net::HTTP.get_response(URI.parse(url)).body

	# extract event information
	doc = REXML::Document.new(xml_data)
	sitecode = "MY1"
 	site = REXML::XPath.first(doc, "//site[@sitecode='#{sitecode}']")
	haml :index, :locals => { :title => "London's invisible smog - using Google streetview to see London pollution", :site => site }
end

