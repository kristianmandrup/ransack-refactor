module Ransack::Adapters::ActiveRecord
  class JoinDependency < Ransack::Context
    attr_reader :join_dependency, :name, :join_type

    # use SearchParams ?
    attr_reader :object, :klass, :parent, :relation

    # Because the AR::Associations namespace is insane
    JoinDependency = ::ActiveRecord::Associations::JoinDependency
    JoinPart = JoinDependency::JoinPart

    def initialize (object, options = {})
      super
    end

    def resolve relation
      relation.respond_to?(:join_dependency) ? relation.join_dependency : build_join_dependency(relation)      
    end

    # CRAZY BIG METHOD!
    def build_or_find_association
      return found_association if found_association
      association_from_join
    end

    protected

    def association_from_join
      join_dependency.send(:build, Polyamorous::Join.new(name, join_type, klass), parent)
      found_association = join_dependency.join_associations.last
      # Leverage the stashed association functionality in AR
      @object = object.joins(found_association)
      found_association
    end

    def found_association 
      @found_association ||= join_dependency.join_associations.detect do |assoc|
        assoc.reflection.name == name &&
        assoc.parent == parent &&
        (!klass || assoc.reflection.klass == klass)
      end
    end

    def build_join_dependency(relation)      
      join_nodes.each do |join|
        add_alias join
      end
      join_dependency.graft(*stashed_association_joins)
    end

    protected

    def add_alias join
      join_dependency.alias_tracker.aliases[join.left.name.downcase] = 1
    end

    def association_joins
      @association_joins ||= buckets['association_join'] || []
    end

    def stashed_association_joins
      @stashed_association_joins ||= buckets['stashed_join'] || []
    end

    def join_nodes
      @join_nodes ||= buckets['join_node'] || []
    end


    def join_list 
      @join_list ||= relation.send :custom_join_ast, relation.table.from(relation.table), string_joins
    end

    def join_dependency
      @join_dependency ||= JoinDependency.new(
        relation.klass,
        association_joins,
        join_list
      )
    end

    def string_joins
      @string_joins ||= (buckets['string_join'] || []).map { |x|
        x.strip
      }.uniq
    end

    def buckets 
      @buckets ||= relation.joins_values.group_by do |join|
        case join
        when String
          'string_join'
        when Hash, Symbol, Array
          'association_join'
        when join_association?
          'stashed_join'
        when node_join?
          'join_node'
        else
          raise 'unknown class: %s' % join.class.name
        end
      end
    end

    def join_association?
      ::ActiveRecord::Associations::JoinDependency::JoinAssociation
    end

    def node_join?
      Arel::Nodes::Join
    end
  end
end