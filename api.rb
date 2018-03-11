require 'sinatra/base'
require './graph/graph.rb'
require './graph/actor_node.rb'
require './graph/movie_node.rb'
require './graph/adjacent_node.rb'
require 'json'

$graph = Graph.new
$graph.json_to_graph('graph.json')

class API < Sinatra::Base

  # This route gets the actors filtered by attribute
  get '/actors' do
    begin
      content_type :json
      name = params['name']
      age = params['age']
      actor_nodes_subset = []
      if name != nil
        actor_nodes_subset = $graph.filter_actor_node_by_name($graph.actor_nodes, name)
        if age != nil
          actor_nodes_subset = $graph.filter_actor_node_by_age(actor_nodes_subset, age.to_i)
        end
      elsif age != nil
        actor_nodes_subset = $graph.filter_actor_node_by_age($graph.actor_nodes, age.to_i)
      end
      for i in 0..actor_nodes_subset.length-1
        actor_nodes_subset[i] = actor_nodes_subset[i].actor_node_to_json
      end
      status 200
      JSON.pretty_generate(actor_nodes_subset)
    rescue
      status 400
    end
  end

  # This route gets the actor with the corresponding actor_name
  get '/actors/:actor_name' do
    content_type :json
    name = params['actor_name']
    name = name.gsub("_", " ")

    if($graph.is_actor_node_in_graph(name))
      status 200
      actor_node = $graph.get_actor_node(name)
      actor_node.actor_node_to_json
    else
      status 400
    end
  end

  # This route gets the movies filtered by attribute
  get '/movies' do
    begin
      content_type :json
      name = params['name']
      year = params['year']
      movie_nodes_subset = []
      if name != nil
        movie_nodes_subset = $graph.filter_movie_node_by_name($graph.movie_nodes, name)
        if year != nil
          movie_nodes_subset = $graph.filter_movie_node_by_year(movie_nodes_subset, year.to_i)
        end
      elsif year != nil
        movie_nodes_subset = $graph.filter_movie_node_by_year($graph.movie_nodes, year.to_i)
      end
      for i in 0..movie_nodes_subset.length-1
        movie_nodes_subset[i] = movie_nodes_subset[i].movie_node_to_json
      end
      status 200
      JSON.pretty_generate(movie_nodes_subset)
    rescue
      status 400
    end
  end

  # This route gets the movie with the corresponding movie_name
  get '/movies/:movie_name' do
    content_type :json
    name = params['movie_name']
    name = name.gsub("_", " ")

    if($graph.is_movie_node_in_graph(name))
      status 200
      movie_node = $graph.get_movie_node(name)
      movie_node.movie_node_to_json
    else
      status 400
    end
  end

  # This route updates or creates the actor with the given parameters
  put '/actors/:actor_name' do
    begin
      name = params['actor_name']
      name = name.gsub("_", " ")
      payload = JSON.parse(request.body.read)
      name_update = payload["name"]
      age_update = payload["age"]
      total_grossing_value_update = payload["total_grossing_value"]

      if $graph.is_actor_node_in_graph(name)
        actor_node = $graph.get_actor_node(name)
        if name_update != nil then (actor_node.name = name_update) end
        if age_update != nil then (actor_node.age = age_update) end
        if total_grossing_value_update != nil then (actor_node.total_grossing_value = total_grossing_value_update) end
        status 200
      else
        new_actor = ActorNode.new(name_update, age_update.to_i)
        $graph.add_actor_node(new_actor)
        if total_grossing_value_update != nil then (new_actor.total_grossing_value = total_grossing_value_update) end
        status 201
      end
    rescue
      status 400
    end
  end

  # This route updates or creates the movie with the given parameters
  put '/movies/:movie_name' do
    begin
      name = params['movie_name']
      name = name.gsub("_", " ")
      payload = JSON.parse(request.body.read)
      name_update = payload["name"]
      box_office_update = payload["box_office"]
      year_update = payload["year"]

      if $graph.is_movie_node_in_graph(name)
        movie_node = $graph.get_movie_node(name)
        if name_update != nil then (movie_node.name = name_update) end
        if box_office_update != nil then (movie_node.box_office = box_office_update) end
        if year_update != nil then (movie_node.year = year_update) end
        status 200
      else
        new_movie = MovieNode.new(name_update, box_office_update.to_f, year_update.to_i)
        $graph.add_movie_node(new_movie)
        status 201
      end
    rescue
      status 400
    end
  end

  # This route creates a new actor with the given parameters
  post '/actors' do
    begin
      payload = JSON.parse(request.body.read)
      name = payload["name"]
      age = payload["age"]
      new_actor = ActorNode.new(name, age.to_i)
      $graph.add_actor_node(new_actor)
      status 201
    rescue
      status 400
    end
  end

  # This route creates a new movie with the given parameters
  post '/movies' do
    begin
      payload = JSON.parse(request.body.read)
      name = payload["name"]
      box_office = payload["box_office"]
      year = payload["year"]
      new_movie = MovieNode.new(name, box_office.to_f, year.to_i)
      $graph.add_movie_node(new_movie)
      status 201
    rescue
      status 400
    end

  end

  # This route deletes the actor with the given actor_name
  delete '/actors/:actor_name' do
    name = params['actor_name']
    name = name.gsub("_", " ")

    if($graph.is_actor_node_in_graph(name))
      status 200
      $graph.delete_actor_node(name)
    else
      status 400
    end
  end

  # This route deletes the movie with the given movie_name
  delete '/movies/:movie_name' do
    name = params['movie_name']
    name = name.gsub("_", " ")

    if($graph.is_movie_node_in_graph(name))
      status 200
      $graph.delete_movie_node(name)
    else
      status 400
    end
  end
end

#run API.run!