module Ransack::Adapters::ActiveRecord
  class Evaluator
    attr_reader :search, :visitor, :options

    def initialize search, options = {}
      @search, @options = [search, options]
    end

    # THE MAIN Search Evaluator
    def evaluate
      distinct? ? distinct_relation : relation
    end

    protected

    def relation
      @relation ||= searcher.sort!
    end

    def visitor
      @visitor ||= Visitor.new
    end

    def searcher
      sorting? ? sort_searcher : basic_search
    end

    def basic_searcher
      @basic_searcher ||= BasicSearcher.new(visitor, object)
    end

    def sort_searcher
      @sort_searcher ||= SortSearch.new(visitor, object, search, klass, options)
    end

    class BasicSearcher
      delegate :visitor, :object, :search, :options, :to => :search_params

      def initialize search_params
        @search_params = search_params
      end

      def search!
        object.where(criteria)
      end

      def criteria
        visitor.accept(search.base)
      end
    end

    class SortSearcher
      attr_reader :search_params

      def initialize search_params
         @search_params = search_params
      end

      def search!
        order_relation.order sort_criteria
      end

      protected

      delegate :visitor, :object, :search, :options, :klass, :relation, :to => :search_params

      def sorting?
        sorts.any?
      end

      def sorts
        search.sorts
      end

      def distinct?
        options[:distinct]
      end

      def order_relation
        relation.except(:order)
      end

      def criteria
        visitor.accept(sorts)
      end

      def distinct_relation
        relation.select("DISTINCT #{klass.quoted_table_name}.*")
      end
    end
  end
end