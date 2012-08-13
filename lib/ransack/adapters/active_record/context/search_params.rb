module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context
    class SearchParams
      attr_reader :visitor, :object, :search, :options, :klass, :relation

      def initialize visitor, object, search, options = {}
        @visitor, @object, @search, @options = [visitor, object, search, options]
        @klass    = options[:klass]
        @relation = options[:relation]
      end

      def extract
        [visitor, object, search, options, klass, relation]
      end

    end
  end
end