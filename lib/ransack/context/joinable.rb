module Ransack
  class Context
    module Joinable
      def join_dependency 
        @join_dependency ||= join_dependency(@object)
      end

      def join_type 
        @join_type ||= options[:join_type] || Arel::OuterJoin
      end
    end
  end
end
