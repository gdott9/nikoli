#!/usr/bin/env ruby

require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/json'

require 'yaml'
require 'coffee-script'
require 'slim'
require 'sass'

class Nikoli < Sinatra::Application
  GAMES = %i{akari hitori nurikabe sudoku}

  set :data_folder, File.expand_path('./data')

  get('/application.css') { scss :application }
  get('/application.js') { coffee :application }

  get('/') { slim :index, locals: {games: GAMES} }

  GAMES.each do |game|
    get("/#{game}") { slim game }
    get("/#{game}.js") { coffee game }
  end

  get "/data/:game.json" do |game|
    data_file = Pathname.new(File.join(settings.data_folder, game))
    halt(404) unless data_file.directory?

    json data_file.children(false).select { |path| path.to_s.end_with?('.yml') }
      .map { |path| path.to_s.sub(/.yml$/, '') }
  end

  get "/data/:game/:file.json" do |game, file|
    data_file = File.expand_path(File.join(settings.data_folder, game, "#{file}.yml"))
    halt(404) unless File.exist?(data_file)

    data = YAML.load_file(data_file)['data']
    json Array(data).sample
  end

  run! if app_file == $0
end
