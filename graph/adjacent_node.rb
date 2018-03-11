class AdjacentNode
  attr_accessor :name, :weight

  # This is the constructor for the AdjacentNode class.
  def initialize(name, weight = nil)
    @name = name
    @weight = weight
  end

  # This converts the node to a hash.
  def to_hash
    {
        name: @name,
        weight: @weight
    }
  end
end