module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context
    class AssociationContext
      include Ransack::Adapters::ActiveRecord::Context::Helper

      attr_reader :remainder, :found_assoc, :str, :segments, :assoc, :poly_class
      attr_accessor :auth_object

      def initialize str, klass
        @remainder = []
        @found_assoc = nil
        @str = str
        @segments = str.split(/_/)
        @klass = klass
      end

      def resolve
        return false unless segments.size > 1
        while segments_remain_to_resolve? do
          unpolymorphize        
          break true if found_assoc && attribute_association?
          false
        end
      end

      protected

      def segments_remain_to_resolve?
        !found_assoc && remainder.unshift(segments.pop) && segments.size > 0      
      end

      def attribute_association?
        self.new(remainder_association_name, assoc_klass).resolve
      end

      def assoc_klass 
        poly_class || found_assoc.klass
      end

      def get_association(str, parent = @base)
        puts "get_association: #{str}, #{parent}"
        klass = classifier(parent).classify
        ransackable_association?(str, klass) &&
        klass.reflect_on_all_associations.detect {|a| a.name.to_s == str}
      end    

      include Ransack::Context::Ransackable
      include Ransack::Context::Polymorph
    end
  end
end