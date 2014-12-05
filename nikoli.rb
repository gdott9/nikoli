#!/usr/bin/env ruby

require 'sinatra'
require 'coffee-script'
require 'slim'
require 'sass'

get('/application.css') { scss :application }

get('/') { slim :index }

%i{nurikabe}.each do |game|
  get("/#{game}") { slim game }
  get("/#{game}.js") { coffee game }
end
