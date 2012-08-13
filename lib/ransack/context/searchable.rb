module Ransack
  class Context
    module Searchable
      def searchable_attributes(str = '')
        traverse(str).ransackable_attributes(auth_object)
      end

      def searchable_associations(str = '')
        traverse(str).ransackable_associations(auth_object)
      end
    end
  end
end