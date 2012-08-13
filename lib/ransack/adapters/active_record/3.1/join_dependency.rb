module Ransack::Adapters::ActiveRecord
  class JoinDependency < Ransack::Context
    # Because the AR::Associations namespace is insane
    JoinDependency = ::ActiveRecord::Associations::JoinDependency
    JoinPart = JoinDependency::JoinPart

    def initialize (object, options = {})
      super
    end

    def resolve relation
      puts "join_dependency: #{relation}"
      relation.respond_to?(:join_dependency) ? relation.join_dependency : build_join_dependency(relation)      
    end

    # CRAZY BIG METHOD!
    def build_or_find_association(name, parent = @base, klass = nil)
      puts "build_or_find_association: #{name}, #{parent}, #{klass}"
      found_association = @join_dependency.join_associations.detect do |assoc|
        assoc.reflection.name == name &&
        assoc.parent == parent &&
        (!klass || assoc.reflection.klass == klass)
      end
      unless found_association
        @join_dependency.send(:build, Polyamorous::Join.new(name, @join_type, klass), parent)
        found_association = @join_dependency.join_associations.last
        # Leverage the stashed association functionality in AR
        @object = @object.joins(found_association)
      end

      found_association
    end

    protected

    # CRAZY BIG METHOD!
    def build_join_dependency(relation)
      puts "build_join_dependency: #{relation}"

      # UGLY AS HELL!!!
      buckets = relation.joins_values.group_by do |join|
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

      association_joins         = buckets['association_join'] || []
      stashed_association_joins = buckets['stashed_join'] || []
      join_nodes                = buckets['join_node'] || []
      string_joins              = (buckets['string_join'] || []).map { |x|
        x.strip
      }.uniq

      join_list = relation.send :custom_join_ast, relation.table.from(relation.table), string_joins

      join_dependency = JoinDependency.new(
        relation.klass,
        association_joins,
        join_list
      )

      join_nodes.each do |join|
        join_dependency.alias_tracker.aliases[join.left.name.downcase] = 1
      end

      join_dependency.graft(*stashed_association_joins)
    end

    def join_association?
      ::ActiveRecord::Associations::JoinDependency::JoinAssociation
    end

    def node_join?
      Arel::Nodes::Join
    end
  end
end