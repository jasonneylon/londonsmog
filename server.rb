# encoding: UTF-8
# Encoding.default_internal = Encoding.default_external = 'UTF-8'

require "bundler/setup"
require "sinatra"
require 'sinatra/contrib'
require "haml"
require "sass"
require "sinatra/reloader" if development?

require File.join(File.dirname(__FILE__), *%w[lib helpers])

include Helpers



configure do
  set :haml, { :attr_wrapper => '"', :format => :html5 }
end


get "/" do
  haml :index, :locals => { :title => "London's invisible smog - using Google streetview to see London pollution" }
end

