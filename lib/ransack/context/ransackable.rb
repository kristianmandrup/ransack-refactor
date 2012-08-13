module Ransack
  class Context
    module Ransackable
      def ransackable_attributes(auth_object = nil)
        column_names + _ransackers.keys
      end

      def ransackable_associations(auth_object = nil)
        reflect_on_all_associations.map {|a| a.name.to_s}
      end
    end
  end
end