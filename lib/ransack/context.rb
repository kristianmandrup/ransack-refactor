require 'ransack/visitor'

require 'ransack/association_path'
require 'ransack/polymorph'
require 'ransack/ransackable'
require 'ransack/searchable'

module Ransack
  class Context
    attr_reader :search, :object, :klass, :base, :engine, :visitor
    attr_accessor :auth_object, :search_key

    def initialize(object, options = {})
      @object = object.scoped
      @klass = @object.klass      
    end

    # Convert a string representing a chain of associations and an attribute
    # into the attribute itself
    def contextualize(str)
      parent, attr_name = @bind_pairs[str]
      table_for(parent)[attr_name]
    end

    def bind(object, str)
      object.parent, object.attr_name = @bind_pairs[str]
    end

    # Recursive traversing!
    # Create separate class for this!
    def traverse(str, base = @base)
      traverser(str, base).traverse
    end

    def traverser
      Traverser.new(str, base)
    end

    def association_path name
      association_path_resolver.resolve
    end

    protected

    include Polymorph
    include Ransackable
    include Searchable
    include Joinable

    def bind_pairs       
      @bind_pairs = Hash.new do |hash, key|
        parent, attr_name = get_parent_and_attribute_name(key.to_s)
        if parent && attr_name
          hash[key] = [parent, attr_name]
        end
      end
    end

    def search_key 
      @search_key ||= options[:search_key] || Ransack.options[:search_key]
    end

    def base
      @base ||= @join_dependency.join_base
    end

    def engine
      @engine ||= @base.arel_engine
    end

    def default_table 
      @default_table ||= arel_table
    end

    def arel_table
      Arel::Table.new(@base.table_name, :as => @base.aliased_table_name, :engine => @engine)
    end

    def association_path_resolver
      @association_path_resolver ||= AssociationPathResolver.new # some arg(s)!?
    end
  end
end