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


require File.join(File.dirname(__FILE__), *%w[lib helpers])

include Helpers

configure do
  set :haml, { :attr_wrapper => '"', :format => :html5 }

 Sass::Plugin.compiler.add_template_location("./public/sass")
 use Sass::Plugin::Rack
end


get "/" do
	aqlevels = {
	 "1" => "Low", 
	 "2" => "Low", 
	 "3" => "Low", 
	 "4" => "Moderate", 
	 "5" => "Moderate", 
	 "6" => "Moderate", 
	 "7" => "High", 
	 "8" => "High", 
	 "9" => "High", 
	 "10" => "Very high", 
	}

	url = "http://www.londonair.org.uk/london/rss/rssLaGroupXml.asp?lagroup=LAQNiPhone"

	xml_data = Net::HTTP.get_response(URI.parse(url)).body
	# extract event information
	doc = REXML::Document.new(xml_data)
	# sitecode = "MY1"
 	sites = REXML::XPath.each(doc, "//site").find_all do |x| 
	 	next if x.elements.first.attributes["aqindex"] == "0" or x.attributes["sitename"] =~ /London/ 
	 	# latitude =  BigDecimal.new(x.attributes["latitude"])
	 	# longitude = BigDecimal.new(x.attributes["longitude"])
	 	# next if longitude > 0.15 or longitude < -0.13
	 	# puts "#{x.attributes["sitename"]}, #{latitude}, #{longitude}"
	 	puts "#{x.attributes["sitename"]}, #{x.attributes['sitetype']}"
	 	# next if longitude > 0.25
	 	# next if longitude < -0.25
	 	next if x.attributes["sitetype"] == "rural"
	 	true
	 end
 # 	aqindex = site.elements.first.attributes["aqindex"] 
 # 	aqindex = params["aqindex"] if params["aqindex"]
	haml :index, :locals => { 
		:title => "London's invisible smog - using Google streetview to see London pollution", 
		:aqlevels => aqlevels,
		:sites => sites }
end


get "/area" do
	aqlevels = {
	 "1" => "Low", 
	 "2" => "Low", 
	 "3" => "Low", 
	 "4" => "Moderate", 
	 "5" => "Moderate", 
	 "6" => "Moderate", 
	 "7" => "High", 
	 "8" => "High", 
	 "9" => "High", 
	 "10" => "Very high", 
	}

	url = "http://www.londonair.org.uk/london/rss/rssLaGroupXml.asp?lagroup=LAQNiPhone"

	xml_data = Net::HTTP.get_response(URI.parse(url)).body

	# extract event information
	doc = REXML::Document.new(xml_data)
	sitecode = params[:sitecode] || "MY1"
 	site = REXML::XPath.first(doc, "//site[@sitecode='#{sitecode}']")
 	aqindex = site.elements.first.attributes["aqindex"] 
 	aqindex = params["aqindex"] if params["aqindex"]
	haml :area, :locals => { 
		:title => "London's invisible smog - using Google streetview to see London pollution", 
		:site => site, 
		:aqindex => aqindex,
		:aqlevels => aqlevels }
end

