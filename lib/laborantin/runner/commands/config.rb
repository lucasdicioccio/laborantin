
module Laborantin::Commands
  module Config

    class ConfigError < StandardError ; end 

    class PathError < ConfigError ; end 

    class RootNotHashError < PathError
      def initialize
        super "The root node of the config must be a Hash"
      end
    end

    class PathNotHashError < PathError
      def initialize(path)
        super "There already is a non-hash value at: '#{path}'."
      end
    end

    # Stores the runner configuration into the configuration file.
    def save_config
      raise RootNotHashError unless runner.config.is_a? Hash
      File.open(runner.config_path, 'w') do |f|
        f.puts YAML.dump(runner.config)
      end
    end

    # Interprets a string provided path as an array of symbols (the nodes of the config tree).
    def interpret_path(path)
      path.split(':').map{|i| i.to_sym}
    end

    # Interprets a string provided value into a ruby object.
    # * if val is 'true' then the true object of class TrueClass
    # * if val is 'false' then the false object of class FalseClass * if val is
    # a string that can be read like a decimal, it's a decimal (Fixnum or
    # Bignum), unlike in ruby interpreter 1_000 is not valid for 1000, see
    # source for details * otherwise the string val itself
    def interpret_value(val)
      case val
      when 'true'
        true
      when 'false'
        false
      when val.to_i.to_s == val
        val.to_i
      else
        val
      end
    end

    # Given a path made of an array of nodes (i.e., symbols to respect the syntax).
    # Returns the object corresponding to this node in the configuration tree.
    # Returns nil if there is no such object.
    # If path is empty, simply returns the root node (i.e., the runner's config).
    def get_node(path)
      tree = runner.config
      return tree if path.empty? #easy solution
      path = path.clone
      while (node = path.shift)
        if tree.is_a? Hash
          if path.empty? #terminal node
            return tree[node]
          else 
            tree = tree[node]
          end
        else #error
          return nil
        end
      end
    end

    # Creates a path structure in the runner's config.
    # If there already a non-hash node, will raise an error.
    def build_path(path_arg)
      path = path_arg.clone
      tree = runner.config
      while (node = path.shift)
        case tree[node]
        when Hash
          tree = tree[node]
        when NilClass
          tree[node] = Hash.new
          tree = tree[node]
        else
          raise PathNotHashError.new(orig.join(':'))
        end
      end
    end

    class Get < Laborantin::Command
      include Config
      describe "Show a configuration tree"
      option(:path) do
        describe "a column separated path of the config"
        short '-p'
        long '--path=OPTIONAL'
        type String
        default ''
      end
      execute do
        path = interpret_path(opts[:path])
        p get_node(path)
      end
    end

    class Set < Laborantin::Command
      include Config
      describe "Set a configuration node"
      option(:path) do
        describe "a column separated path of the config"
        short '-p'
        long '--path=MANDATORY'
        type String
        default ''
      end
      option(:value) do
        describe "the value to set the node to, interprets true, false, decimal integers, or string"
        short '-v'
        long '--value=MANDATORY'
        type String
        default ''
      end
      execute do
        path = interpret_path(opts[:path])
        value = interpret_value(opts[:value])
        if path.empty?
          puts "--path= should not be empty"
        end
        if value.is_a? String and value.empty?
          puts "--value= should not be empty"
        end

        node = path.pop
        begin
          build_path(path)
        rescue PathError => err
          puts err
          exit
        end
        get_node(path)[node] = value
        save_config
      end
    end

    class Del < Laborantin::Command
      include Config
      describe "Deletes a node from the configuration tree."
      option(:path) do
        describe "a column separated path"
        short '-p'
        long '--path=MANDATORY'
        type String
        default ''
      end
      execute do
        path = interpret_path(opts[:path])
        if path.empty?
          puts "Cannot delete empty path, if you really want, remove #{runner.config_path}"
        end
        node = path.pop
        tree = get_node(path)
        tree.delete(node)
        save_config
      end
    end
  end
end
