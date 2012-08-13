module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context
    module TableHelper
      def table_for(parent)
        puts "table_for: #{parent} -> #{parent.table}"
        parent.table
      end

      def type_for(attr)
        puts "type_for: #{attr}"
        return nil unless attr && attr.valid?
        name    = attr.arel_attribute.name.to_s
        table   = attr.arel_attribute.relation.table_name

        puts "name: #{name}"
        puts "table: #{table}"

        unless @engine.connection_pool.table_exists?(table)
          raise "No table named #{table} exists"
        end

        @engine.connection_pool.columns_hash[table][name].type
      end
    end
  end
end