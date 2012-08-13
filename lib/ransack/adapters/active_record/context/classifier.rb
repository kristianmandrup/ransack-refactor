module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context
    class Classifier
      attr_reader :obj

      def initialize obj
        @obj = obj
      end

      def classify
        return obj if ar_class?
        return obj.klass if obj.respond_to? :klass        
        return obj.active_record if obj.respond_to? :active_record

        raise ArgumentError, "Don't know how to klassify #{obj}"
      end    

      def ar_class?
        Class === obj && ::ActiveRecord::Base > obj
      end
    end
  end
end