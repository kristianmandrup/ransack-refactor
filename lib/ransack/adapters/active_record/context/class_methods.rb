module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context
    # Active Record specific - put in AR module!
    module ClassMethods
      def for(object, options = {})
        context = Class === object ? for_class(object, options) : for_object(object, options)
        context or raise ArgumentError, "Don't know what context to use for #{object}"
      end

      def for_class(klass, options = {})
        if klass < ActiveRecord::Base
          Adapters::ActiveRecord::Context.new(klass, options)
        end
      end

      def for_object(object, options = {})
        case object
        when ActiveRecord::Relation
          Adapters::ActiveRecord::Context.new(object.klass, options)
        end
      end
    end
  end
end