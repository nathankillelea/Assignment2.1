require 'json'
require './graph/graph.rb'
require './graph/actor_node.rb'
require './graph/movie_node.rb'
require './graph/adjacent_node.rb'
require 'cgi'
require 'active_support/core_ext/enumerable.rb'

class JsonParser

  def self.main
    @graph = json_to_graph('data.json')
    add_incomplete
    delete_incomplete
    @graph.add_weights
    @graph.add_total_grossing_for_actors
    @graph.graph_to_json("data_copy.json")
    @graph.plot_hub_actors(5, 'json_data_connections_plot.png')
    @graph.plot_age_correlation('json_data_age_correlation_plot.png')
  end

  # This function creates a graph from the given data.json file.
  def self.json_to_graph(json_file)
    json_string = File.read(File.expand_path(json_file, "./external_json_support/"), :encoding => 'US-ASCII')
    data = JSON.parse(json_string)
    new_graph = Graph.new
    data.each do |nodes|
      i = 0
      nodes.each do |node|
        adjacency_list = []
        if node[1]['json_class'] == 'Actor'
          node[1]['movies'].each do |name|
            adjacency_list << AdjacentNode.new(name)
          end
          name = CGI::unescape(node[1]['name'])
          new_graph.actor_nodes << ActorNode.new(name, node[1]['age'])
          new_graph.actor_nodes[i].adjacency_list = adjacency_list
        else
          node[1]['actors'].each do |name|
            adjacency_list << AdjacentNode.new(name)
          end
          name = CGI::unescape(node[1]['name'])
          new_graph.movie_nodes << MovieNode.new(name, node[1]['box_office'], node[1]['year'])
          new_graph.movie_nodes[i].adjacency_list = adjacency_list
        end
        i += 1
      end
    end

    return new_graph
  end

  # This function adds the actor/movie to the corresponding actor/movie if they should be connected.
  def self.add_incomplete
    @graph.movie_nodes.each do |movie_node|
      movie_node.adjacency_list.each do |actor_adj_node|
        flag = false
        if @graph.is_actor_node_in_graph(actor_adj_node.name)
          actor_node = @graph.get_actor_node(actor_adj_node.name)
          actor_node.adjacency_list.each do |movie_adj_node|
            if movie_adj_node.name == movie_node.name then flag = true end
          end
          if flag == false then actor_node.adjacency_list << AdjacentNode.new(movie_node.name) end
        end
      end
    end
    @graph.actor_nodes.each do |actor_node|
      actor_node.adjacency_list.each do |movie_adj_node|
        flag = false
        if @graph.is_movie_node_in_graph(movie_adj_node.name)
          movie_node = @graph.get_movie_node(movie_adj_node.name)
          movie_node.adjacency_list.each do |actor_adj_node|
            if actor_adj_node.name == actor_node.name then flag = true end
          end
          if flag == false then movie_node.adjacency_list << AdjacentNode.new(actor_node.name) end
        end
      end
    end
  end

  # This function deletes movies/actors if they are not connected to any actors/movies.
  def self.delete_incomplete
    @graph.movie_nodes.reverse_each do |movie_node|
      movie_node.adjacency_list.reverse_each do |actor_adj_node|
        if !@graph.is_actor_node_in_graph(actor_adj_node.name)
          movie_node.adjacency_list.delete(actor_adj_node)
        end
      end
      if movie_node.adjacency_list.length == 0
        @graph.movie_nodes.delete(movie_node)
      end
    end
    @graph.actor_nodes.reverse_each do |actor_node|
      actor_node.adjacency_list.reverse_each do |movie_adj_node|
        if !@graph.is_movie_node_in_graph(movie_adj_node.name)
          actor_node.adjacency_list.delete(movie_adj_node)
        end
      end
      if actor_node.adjacency_list.length == 0
        @graph.actor_nodes.delete(actor_node)
      end
    end
  end

  main
end