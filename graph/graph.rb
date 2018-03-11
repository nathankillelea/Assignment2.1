# Sources:
# https://ex0ns.me/2015/01/30/-ruby-graph-representation/
# http://billleidy.com/blog/advent-of-code-and-graph-data-structure.html
# https://www.geeksforgeeks.org/graph-and-its-representations/
# https://github.com/brianstorti/ruby-graph-algorithms/blob/master/dijkstra/graph.rb
# https://stackoverflow.com/questions/9459447/finding-n-keys-with-highest-value-in-hash-keeping-order

require 'ostruct'
require 'gchart'
require 'json'

class Graph
  attr_accessor :actor_nodes, :movie_nodes

  # This is the constructor for the Graph class.
  def initialize
    @actor_nodes = []
    @movie_nodes = []
  end

  # This function loads .json file into an empty graph.
  def json_to_graph(json_file)
    json_string = File.read(json_file)
    data = JSON.parse(json_string)
    @actor_data = data['actor_nodes']
    @movie_data = data['movie_nodes']
    @actor_nodes = @actor_data.map { |a_n| ActorNode.new(a_n['name'], a_n['age'], a_n['total_grossing_value'],
                                                                 a_n['adjacency_list'].map{ |adj_node| AdjacentNode.new(adj_node['name'], adj_node['weight']) }) }
    @movie_nodes = @movie_data.map { |m_n| MovieNode.new(m_n['name'], m_n['box_office'], m_n['year'],
                                                                 m_n['adjacency_list'].map{ |adj_node| AdjacentNode.new(adj_node['name'], adj_node['weight']) }) }
  end

  # This function converts the graph to a hash.
  def to_hash
    {
        actor_nodes: @actor_nodes,
        movie_nodes: @movie_nodes
    }
  end

  # This function adds an actor node into the graph.
  # @param node The node to be added into the graph
  def add_actor_node(node)
    actor_nodes << node
  end

  # This function adds a movie node into the graph.
  # @param node The node to be added into the graph
  def add_movie_node(node)
    movie_nodes << node
  end

  # This function checks whether the actor node is in the graph.
  # @param name The name of the node to be searched
  # @return [Boolean] This returns true if the node is in the graph and false if not.
  def is_actor_node_in_graph(name)
    actor_nodes.each { |node| (if node.name == name then return true end) }
    return false
  end

  # This function checks whether the movie node is in the graph.
  # @param name The name of the node to be searched
  # @return [Boolean] This returns true if the node is in the graph and false if not.
  def is_movie_node_in_graph(name)
    movie_nodes.each { |node| (if node.name == name then return true end) }
    return false
  end

  # This function gets the actor node for a given name.
  # @param name The name of the actor to be retrieved
  # @return [ActorNode] This returns the actor node corresponding to the given name.
  def get_actor_node(name)
    actor_nodes.each { |node| (if node.name == name then return node end)}
  end

  # This function gets the movie node for a given name.
  # @param name The name of the movie to be retrieved.
  # @return [MovieNode] This returns the movie node corresponding to the given name.
  def get_movie_node(name)
    movie_nodes.each { |node| (if node.name == name then return node end)}
  end

  # This function deletes a movie node and all references from actors to it.
  # @param name The name of the movie to be removed.
  def delete_movie_node(name)
    movie_node = get_movie_node(name)
    movie_node.adjacency_list.each do |actor_adj_node|
      actor_node = get_actor_node(actor_adj_node.name)
      actor_node.adjacency_list.each do |movie_adj_node|
        if movie_adj_node.name == movie_node.name
          actor_node.adjacency_list.delete(movie_adj_node)
        end
      end
    end
    movie_nodes.delete(movie_node)
  end

  # This function deletes an actor node and all references from movies to it.
  # @param name The name of the actor to be removed.
  def delete_actor_node(name)
    actor_node = get_actor_node(name)
    actor_node.adjacency_list.each do |movie_adj_node|
      movie_node = get_movie_node(movie_adj_node.name)
      movie_node.adjacency_list.each do |actor_adj_node|
        if actor_adj_node.name == actor_node.name
          movie_node.adjacency_list.delete(actor_adj_node)
        end
      end
    end
    actor_nodes.delete(actor_node)
  end

  # This function gets the box office amount for a given movie.
  # @param name The name of the movie to find the box office amount for
  # @return [Float] This returns the box office amount corresponding to the given name.
  def get_box_office_amount(name)
    movie_nodes.each{ |node| if node.name == name then return node.box_office end }
  end

  # This function gets the movies containing the given actor.
  # @param name The name of the actor
  # @return [[String]] This returns an array of the movies containing an actor.
  def get_movies_containing_actor(name)
    actor_node = get_actor_node(name)
    if(actor_node != nil)
      movies_containing_actor = []
      actor_node.adjacency_list.each { |movie_adj_node| movies_containing_actor << movie_adj_node.name }
      return movies_containing_actor
    end
  end

  # This function gets the actors starring in the given movie.
  # @param name The name of the movie
  # @return [[String]] This returns an array of the actors starring in a movie.
  def get_actors_in_movie(name)
    movie_node = get_movie_node(name)
    if(movie_node != nil)
      actors_in_movie = []
      movie_node.adjacency_list.each { |actor_adj_node| actors_in_movie << actor_adj_node.name }
      return actors_in_movie
    end
  end

  # This function gets the top X grossing actors.
  # @param amount The number of actors to get
  # @return [[String]] This returns an array of length amount containing the top grossing actors.
  def get_top_grossing_actors(amount)
    sorted_by_grossing = actor_nodes.sort_by { |actor_node| actor_node.total_grossing_value }.reverse
    top_grossing_actors = []
    for i in 0..amount-1
      top_grossing_actors[i] = sorted_by_grossing[i].name
    end
    return top_grossing_actors
  end

  # This function gets the top X oldest actors.
  # @param amount The number of actors to get
  # @return [[String]] This returns an array of length amount containing the oldest actors.
  def get_oldest_actors(amount)
    sorted_by_age = actor_nodes.sort_by { |actor_node| actor_node.age }.reverse
    oldest_actors = []
    for i in 0..amount-1
      oldest_actors[i] = sorted_by_age[i].name
    end
    return oldest_actors
  end

  # This function gets all movies for a given year.
  # @param year The given year
  # @return [[String]] This returns an array of the movies for a given year.
  def get_movies_for_year(year)
    movies = []
    movie_nodes.each{ |movie_node| (if movie_node.year == year then movies << movie_node.name end) }
    return movies
  end

  # This function gets all actors that starred in a movie in a given year.
  # @param year The given year
  # @return [[String]] This returns an array of the actors that starred in a movie in a given year.
  def get_actors_for_year(year) # make sure this works
    actors_for_year = []
    movies = get_movies_for_year(year)
    movie_nodes_subset = []
    movies.each { |movie| movie_nodes_subset << get_movie_node(movie) }
    movie_nodes_subset.each do |movie_node|
      movie_node.adjacency_list.each do |actor_adj_node|
        actors_for_year << actor_adj_node.name
      end
    end
    actors_for_year.uniq
  end

  # This function adds the edge weights to the adjacent_nodes with younger actors being weighted more.
  def add_weights
    movie_nodes.each { |movie_node| movie_node.adjacency_list.sort_by! { |actor_adj_node| get_actor_node(actor_adj_node.name).age } }
    for i in 0..movie_nodes.length-1
      x = 1.0
      box_office_total = movie_nodes[i].box_office.to_f
      weighted_gross = []
      for j in 0..movie_nodes[i].adjacency_list.length-1
        weighted_gross[j] = 0.5**x * movie_nodes[i].box_office.to_f
        box_office_total -= weighted_gross[j].to_f
        x += 1.0
      end
      box_office_total /= movie_nodes[i].adjacency_list.length
      for j in 0..movie_nodes[i].adjacency_list.length-1
        weighted_gross[j] += box_office_total
      end
      for j in 0..movie_nodes[i].adjacency_list.length-1
        actor_adj_node = movie_nodes[i].adjacency_list[j]
        actor_adj_node.weight = weighted_gross[j]
        actor_node = get_actor_node(actor_adj_node.name)
        for k in 0..actor_node.adjacency_list.length-1
          if actor_node.adjacency_list[k].name == movie_nodes[i].name
            actor_node.adjacency_list[k].weight = weighted_gross[j]
          end
        end
      end
    end
  end

  # This function adds the total grossing value for each actor
  def add_total_grossing_for_actors
    for i in 0..actor_nodes.length-1
      sum = 0
      actor_nodes[i].adjacency_list.each{ |movie_adj_node| sum += movie_adj_node.weight }
      actor_nodes[i].total_grossing_value = sum
    end
  end

  # This function gets the hub actors in the graph.
  # @param amount The number of hub actors to get
  # @return [[String]] This returns an array of the hub actors.
  def get_hub_actors(amount)
    hub_actors = []
    actor_nodes.each do |actor_node|
      connected_actors = []
      movies_containing_actor = get_movies_containing_actor(actor_node.name)
      movies_containing_actor.each do |movie_name|
        actors_in_movie = get_actors_in_movie(movie_name)
        actors_in_movie.each { |actor| connected_actors << actor }
      end
      connected_actors = connected_actors.uniq
      actor_node.num_connections = connected_actors.length-1
    end
    sorted_by_num_of_connected_actors = actor_nodes.sort_by { |actor_node| actor_node.num_connections }.reverse
    for i in 0..amount-1
      hub_actors[i] = sorted_by_num_of_connected_actors[i].name
    end
    return hub_actors
  end

  # This function gets the average amount of money earned for actors aged 0-100.
  # @return [[Integer]] This returns an array that contains the average amount of money earned for each age.
  def get_money_per_age
    total_per_age = Array.new(101, 0)
    for i in 0..100
      num_actors = 0
      actor_nodes.each { |actor_node| if actor_node.age == i then (total_per_age[i] += actor_node.total_grossing_value; num_actors += 1) end }
      if num_actors != 0
        total_per_age[i] /= num_actors
      end
    end
    total_per_age
  end

  # Creates a plot for the top connected actors in the graph
  def plot_hub_actors(amount, file_name)
    hub_actors = get_hub_actors(amount)
    num_connected = []
    hub_actors.each do |hub_actor|
      num_connected << get_actor_node(hub_actor).num_connections
    end
    x_axis_label = ""
    for i in 0..hub_actors.length-1
      if i == hub_actors.length-1
        x_axis_label += hub_actors[i]
      else
        x_axis_label += hub_actors[i] + "|"
      end
    end
    bar_chart = Gchart.new(
        :type => 'bar',
        :size => '600x400',
        :title => "Connections Per Actor",
        :bg => 'EFEFEF',
        :data => num_connected,
        :max_value => num_connected[0],
        :min_value => 0,
        :filename => file_name,
        :axis_with_labels => ['x', 'y'],
        :axis_labels => [[x_axis_label]],
        :bar_width_and_spacing => '50,65'
    )
    bar_chart.file
  end

  # Creates a plot to show the correlation between age group and grossing value
  def plot_age_correlation(file_name)
    totals_array = get_money_per_age

    line_chart = Gchart.new(
        :type => 'line',
        :size => '600x400',
        :title => 'Total Grossing Per Age',
        :filename => file_name,
        :axis_with_labels => ['x', 'y'],
        :data => totals_array,
        :axis_range => [nil, [0, 100, 10]]
    )
    line_chart.file
  end

  # This function stores the graph as a .json file
  def graph_to_json(file_name)
    cloned_graph = Marshal.load(Marshal.dump(self))
    json_object = cloned_graph.to_hash
    json_object.each do |type, array|
      for i in 0..array.length-1
        for j in 0..array[i].adjacency_list.length-1
          array[i].adjacency_list[j] = array[i].adjacency_list[j].to_hash
        end
        array[i] = array[i].to_hash
      end
    end
    File.open(file_name, 'w') { |f| f.write(JSON.pretty_generate(json_object)) }
  end

  # This function filters the actor nodes by age.
  # @param actor_nodes_subset, name The actor_nodes array to be searched and the name to be filtered by
  # @return [[ActorNode]] This returns an array of actor nodes.
  def filter_actor_node_by_name(actor_nodes_subset, name)
    filtered_actor_nodes = []
    actor_nodes_subset.each do |actor_node|
      if actor_node.name.include? name
        filtered_actor_nodes << actor_node
      end
    end
    filtered_actor_nodes
  end

  # This function filters the actor nodes by age.
  # @param actor_nodes_subset, name The actor_nodes array to be searched and the age to be filtered by
  # @return [[ActorNode]] This returns an array of actor nodes.
  def filter_actor_node_by_age(actor_nodes_subset, age)
    filtered_actor_nodes = []
    actor_nodes_subset.each do |actor_node|
      if actor_node.age == age
        filtered_actor_nodes << actor_node
      end
    end
    filtered_actor_nodes
  end

  # This function filters the movie nodes by age.
  # @param movie_nodes_subset, name The movie_nodes array to be searched and the name to be filtered by
  # @return [[MovieNode]] This returns an array of movie nodes.
  def filter_movie_node_by_name(movie_nodes_subset, name)
    filtered_movie_nodes = []
    movie_nodes_subset.each do |movie_node|
      if movie_node.name.include? name
        filtered_movie_nodes << movie_node
      end
    end
    filtered_movie_nodes
  end

  # This function filters the movie nodes by age.
  # @param movie_nodes_subset, name The movie_nodes array to be searched and the age to be filtered by
  # @return [[MovieNode]] This returns an array of movie nodes.
  def filter_movie_node_by_year(movie_nodes_subset, year)
    filtered_movie_nodes = []
    movie_nodes_subset.each do |movie_node|
      if movie_node.year == year
        filtered_movie_nodes << movie_node
      end
    end
    filtered_movie_nodes
  end

end