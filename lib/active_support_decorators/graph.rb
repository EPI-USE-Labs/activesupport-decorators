class Graph
  Node = Struct.new(:object) do
    def depends_on
      @depends_on ||= []
    end
  end

  def initialize
    @nodes = []
  end

  def list_by_order
    result = []

    until @nodes.empty?
      nodes_without_dependencies = @nodes.select { |n| n.depends_on.empty? }
      result += nodes_without_dependencies.map { |n| n.object }.sort

      nodes_without_dependencies.each do |to_delete|
        @nodes.delete(to_delete)
        @nodes.each { |n| n.depends_on.delete(to_delete) }
      end
    end

    result
  end

  def add(object)
    find_or_add_node(object)
  end

  def add_with_edge(from_object, to_object)
    fail 'Can not add edge from object to itself' if from_object == to_object
    from_node = find_or_add_node(from_object)
    to_node = find_or_add_node(to_object)
    to_node.depends_on << from_node
    fail 'EMPTY' if from_node.nil?
  end

  private
  def find_or_add_node(object)
    node = @nodes.find { |n| n.object == object }
    unless node
      node = Node.new(object)
      @nodes.push(node)
    end
    node
  end
end
