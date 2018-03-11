class ActorNode
  attr_accessor :name, :age, :total_grossing_value, :num_connections, :adjacency_list

  # This is the constructor for the ActorNode class.
  def initialize(name, age = nil, total_grossing_value = nil, adjacency_list = [])
    @name = name
    @age = age
    @total_grossing_value = total_grossing_value
    @adjacency_list = adjacency_list
  end

  # This converts the node to a hash.
  def to_hash
    {
        name: @name,
        age: @age,
        total_grossing_value: @total_grossing_value,
        adjacency_list: @adjacency_list
    }
  end

  def actor_node_to_json
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