module Ransack::Adapters::ActiveRecord
  class Evaluator
    attr_reader :search, :opts

    def initialize search, opts = {}
      @search, @opts = [search, opts]
    end

    # THE MAIN THING!!!
    def evaluate
      puts "evaluate: #{search}, #{opts}"
      distinct? ? distinct_relation : relation
    end

    def viz
      @viz ||= Visitor.new
    end

    protected

    def relation
      @relation ||= sorting? ? sort_relation : basic_search_relation
    end

    def basic_search_relation
      @object.where(viz.accept(search.base))
    end

    def sorting?
      search.sorts.any?
    end

    def distinct?
      opts[:distinct]
    end

    def sort_relation
      relation.except(:order).order(viz.accept(search.sorts))
    end

    def distinct_relation
      relation.select("DISTINCT #{@klass.quoted_table_name}.*")
    end
  end
end