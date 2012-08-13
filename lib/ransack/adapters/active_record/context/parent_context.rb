module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context
    class ParentContext < AssociationContext

      def do_loop
        while segments_remain_to_resolve? do
          unpolymorphize

          break result if found_assoc?
          end
        end
      end

      protected

      def result      
        [parent, attr_name] = get_parent_and_attribute_name(remainder_association_name, join)
      end

      def join
        join = build_or_find_association(found_assoc.name, parent, klass)
      end
    end
  end
end