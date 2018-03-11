require 'test/unit'
require './graph/graph.rb'
require './graph/actor_node.rb'
require './graph/movie_node.rb'
require './graph/adjacent_node.rb'
require 'active_support/core_ext/enumerable.rb'
require 'json'

class GraphTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @actor1 = ActorNode.new("John Jim")
    @actor1.age = 20
    @actor2 = ActorNode.new("Fred Ward")
    @actor2.age = 30
    @movie1 = MovieNode.new("Creeper")
    @movie1.box_office = 100000
    @movie1.year = 2000
    @graph = Graph.new
    @graph.add_actor_node(@actor1)
    @graph.add_actor_node(@actor2)
    @graph.add_movie_node(@movie1)
    @actor1.adjacency_list << AdjacentNode.new(@movie1.name, 60000)
    @movie1.adjacency_list << AdjacentNode.new(@actor1.name, 60000)
    @actor2.adjacency_list << AdjacentNode.new(@movie1.name, 40000)
    @movie1.adjacency_list << AdjacentNode.new(@actor2.name, 40000)
  end

  def test_boolean_methods
    assert @graph.is_actor_node_in_graph(@actor1.name)
    assert @graph.is_actor_node_in_graph(@actor2.name)
    assert !@graph.is_actor_node_in_graph("Bon Jovi")
  end

  def test_get_methods
    assert_equal @actor1, @graph.get_actor_node(@actor1.name)
    assert_equal @actor2, @graph.get_actor_node(@actor2.name)
    assert_not_equal @actor1, @graph.get_actor_node("john")
    assert_not_equal @actor1, @graph.get_actor_node(@actor2.name)
  end

  def test_queries
    # 1. Find how much a movie has grossed
    assert_equal @movie1.box_office, @graph.get_box_office_amount(@movie1.name)
    # 2. List which movies an actor has worked in
    movies = @graph.get_movies_containing_actor(@actor1.name)
    assert movies.include? @movie1.name
    assert movies.exclude? "James Bond"
    # 3. List which actors worked in a movie
    actors = @graph.get_actors_in_movie(@movie1.name)
    assert actors.include? @actor1.name
    assert actors.include? @actor2.name
    assert actors.exclude? "Johnny Bravo"
    # 4. List the top X actors with the most total grossing value
    top_grossing = @graph.get_top_grossing_actors(1)
    assert top_grossing.include? @actor1.name
    assert top_grossing.exclude? @actor2.name
    # 5. List the oldest X actors
    oldest = @graph.get_oldest_actors(1)
    assert oldest.exclude? @actor1.name
    assert oldest.include? @actor2.name
    # 6. List all the movies for a given year
    movies_for_year = @graph.get_movies_for_year(2000)
    assert movies_for_year.include? @movie1.name
    assert movies_for_year.exclude? "Sharknado"
    # 7. List all the actors for a given year
    actors_for_year = @graph.get_actors_for_year(2000)
    assert actors_for_year.include? @actor1.name
    assert actors_for_year.include? @actor2.name
    assert actors_for_year.exclude? "Jim Bone"
  end

  def test_add_weights_and_add_total_grossing
    actor1 = ActorNode.new("Younger Man")
    actor1.age = 20
    actor2 = ActorNode.new("Older Man")
    actor2.age = 60
    movie1 = MovieNode.new("Big Movie")
    movie1.box_office = 50000000
    graph = Graph.new
    graph.add_actor_node(actor1)
    graph.add_actor_node(actor2)
    graph.add_movie_node(movie1)
    actor1.adjacency_list << AdjacentNode.new(movie1.name)
    movie1.adjacency_list << AdjacentNode.new(actor1.name)
    actor2.adjacency_list << AdjacentNode.new(movie1.name)
    movie1.adjacency_list << AdjacentNode.new(actor2.name)

    graph.add_weights
    graph.add_total_grossing_for_actors

    assert actor1.total_grossing_value > actor2.total_grossing_value
  end

  def test_get_hub_actors
    actor1 = ActorNode.new("John Jim")
    actor1.age = 20
    actor2 = ActorNode.new("Fred Ward")
    actor2.age = 30
    actor3 = ActorNode.new("Bob Law")
    actor3.age = 34
    movie1 = MovieNode.new("Creeper")
    movie1.box_office = 100000
    movie1.year = 2000
    movie2 = MovieNode.new("New Movie")
    movie2.box_office = 40000
    movie2.year = 2002
    graph = Graph.new
    graph.add_actor_node(actor1)
    graph.add_actor_node(actor2)
    graph.add_actor_node(actor3)
    graph.add_movie_node(movie1)
    graph.add_movie_node(movie2)
    actor1.adjacency_list << AdjacentNode.new(movie1.name, 60000)
    movie1.adjacency_list << AdjacentNode.new(actor1.name, 60000)
    actor2.adjacency_list << AdjacentNode.new(movie1.name, 40000)
    movie1.adjacency_list << AdjacentNode.new(actor2.name, 40000)
    actor1.adjacency_list << AdjacentNode.new(movie2.name, 30000)
    movie2.adjacency_list << AdjacentNode.new(actor1.name, 30000)
    actor3.adjacency_list << AdjacentNode.new(movie2.name, 10000)
    movie2.adjacency_list << AdjacentNode.new(actor3.name, 10000)

    name = graph.get_hub_actors(1)
    assert_equal name[0], actor1.name

    graph.plot_hub_actors(3, 'testing_connections_plot.png')
  end

  def test_get_money_per_age
    @actor1.total_grossing_value = 60000
    @actor2.total_grossing_value = 40000
    money_per_age = @graph.get_money_per_age
    assert_equal money_per_age[20], 60000
    assert_equal money_per_age[30], 40000
    @graph.plot_age_correlation('testing_age_correlation_plot.png')
  end

  def test_graph_to_json
    @graph.graph_to_json('testing_graph.json')
  end

  def test_filter_movie_node_by_name
    movies = @graph.filter_movie_node_by_name(@graph.movie_nodes,"Creeper")
    assert_equal movies[0].name, @movie1.name
  end

  def test_filter_movie_node_by_year
    movies = @graph.filter_movie_node_by_year(@graph.movie_nodes,2000)
    assert_equal movies[0].name, @movie1.name
  end

  def test_filter_actor_node_by_name
    actors = @graph.filter_actor_node_by_name(@graph.actor_nodes,"Jim")
    assert_equal actors[0].name, @actor1.name
  end

  def test_filter_actor_node_by_age
    actors = @graph.filter_actor_node_by_age(@graph.actor_nodes,20)
    assert_equal actors[0].name, @actor1.name
  end

  def test_delete
    @graph.delete_movie_node(@movie1.name)
    assert @graph.movie_nodes.exclude? @movie1
    @graph.delete_actor_node(@actor1.name)
    assert @graph.actor_nodes.exclude? @actor1
  end
end