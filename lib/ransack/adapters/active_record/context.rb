require 'ransack/context'
require 'ransack/adapters/active_record/3.1/context'
require 'polyamorous'

# require context helpers
%w{class_method associater association_context classifier 
  evaluator join_dependency parent_context search_params}.each do |helper|
  require "ransack/adapters/active_record/context/#{helper}"
end

module Ransack
  module Adapters
    module ActiveRecord
      class Context < ::Ransack::Context
        # Redefine a few things that have changed with 3.2.
        extend ClassMethods

        def initialize(object, options = {})
          super
          @visitor = @engine.connection.visitor
        end
        
        def type_for(attr)
          return nil unless attr && attr.valid?
          name    = attr.arel_attribute.name.to_s
          table   = attr.arel_attribute.relation.table_name

          unless @engine.connection.table_exists?(table)
            raise "No table named #{table} exists"
          end

          @engine.connection.schema_cache.columns_hash[table][name].type
        end
        
        def evaluate(search, opts = {})
          viz = Visitor.new
          relation = @object.where(viz.accept(search.base))
          if search.sorts.any?
            relation = relation.except(:order).order(viz.accept(search.sorts))
          end
          opts[:distinct] ? relation.uniq : relation
        end
        
      end
    end
  end
end