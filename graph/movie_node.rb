class MovieNode
  attr_accessor :name, :box_office, :year, :adjacency_list

  # This is the constructor for the MovieNode class.
  def initialize(name, box_office = nil, year = nil, adjacency_list = [])
    @name = name
    @box_office = box_office
    @year = year
    @adjacency_list = adjacency_list
  end

  # This converts the node to a hash.
  def to_hash
    {
        name: @name,
        box_office: @box_office,
        year: @year,
        adjacency_list: @adjacency_list
    }
  end

  def movie_node_to_json
    cloned_node = Marshal.load(Marshal.dump(self))
    json_object = cloned_node.to_hash
    json_object.each do |type, array|
      if type.to_s == 'adjacency_list'
        for i in 0..array.length-1
          array[i] = array[i].to_hash
        end
      end
    end
    JSON.pretty_generate(json_object)
  end
end