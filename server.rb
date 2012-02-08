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

require 'bigdecimal'
require 'ostruct'
require 'json'

require File.join(File.dirname(__FILE__), *%w[lib helpers])

include Helpers

configure do
  set :haml, { :attr_wrapper => '"', :format => :html5 }

 Sass::Plugin.compiler.add_template_location("./public/sass")
 use Sass::Plugin::Rack
end

aqlevels = {
	1 => "Low", 
	2 => "Low", 
	3 => "Low", 
	4 => "Moderate", 
	5 => "Moderate", 
	6 => "Moderate", 
	7 => "High", 
	8 => "High", 
	9 => "High", 
	10 => "Very high", 
}


get "/" do

	url = "http://www.londonair.org.uk/london/rss/rssLaGroupXml.asp?lagroup=LAQNiPhone"

	xml_data = Net::HTTP.get_response(URI.parse(url)).body
	# extract event information
	doc = REXML::Document.new(xml_data)
 	sites = REXML::XPath.each(doc, "//site")

	sites = sites.map do |x| 
	 	aqindex = x.elements.map {|species| species.attributes["aqindex"].to_i }.max
	 	next if aqindex == 0
		{
			:sitename => x.attributes["sitename"], :sitecode => x.attributes["sitecode"], 
			:latitude => x.attributes["latitude"], :longitude => x.attributes["longitude"], :aqindex => aqindex
		} 
	end.compact

 	haml :index, :locals => { 
		:title => "London's invisible smog - using Google streetview to see London pollution", 
		:aqlevels => aqlevels,
		:sites => sites }
end


get "/area" do

	url = "http://www.londonair.org.uk/london/rss/rssLaGroupXml.asp?lagroup=LAQNiPhone"

	xml_data = Net::HTTP.get_response(URI.parse(url)).body

	# extract event information
	doc = REXML::Document.new(xml_data)
	sitecode = params[:sitecode] || "MY1"
 	site = REXML::XPath.first(doc, "//site[@sitecode='#{sitecode}']")
	aqindex = site.elements.map {|species| species.attributes["aqindex"].to_i }.max
 	aqindex = params["aqindex"].to_i if params["aqindex"]
	haml :area, :locals => { 
		:title => "London's invisible smog - using Google streetview to see London pollution", 
		:site => site, 
		:aqindex => aqindex,
		:aqlevels => aqlevels }
end

