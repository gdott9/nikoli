#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/json'

require 'yaml'
require 'coffee-script'
require 'slim'
require 'sass'

GAMES = %i{hitori nurikabe sudoku}

set :data_folder, File.expand_path('./data')

get('/application.css') { scss :application }
get('/application.js') { coffee :application }

get('/') { slim :index, locals: {games: GAMES} }

GAMES.each do |game|
  get("/#{game}") { slim game }
  get("/#{game}.js") { coffee game }
end

get "/data/:game/:file.json" do |game, file|
  data_file = File.join(settings.data_folder, game, "#{file}.yml")
  halt(404) unless File.exist?(data_file)

  json YAML.load_file(data_file).sample
end
