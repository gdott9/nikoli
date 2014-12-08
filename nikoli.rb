#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/content_for'

require 'coffee-script'
require 'slim'
require 'sass'

GAMES = %i{hitori nurikabe sudoku}

get('/application.css') { scss :application }
get('/application.js') { coffee :application }

get('/') { slim :index, locals: {games: GAMES} }

GAMES.each do |game|
  get("/#{game}") { slim game }
  get("/#{game}.js") { coffee game }
end
