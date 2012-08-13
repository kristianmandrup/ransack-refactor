module Ransack
  class Context
    module Polymorph
      def unpolymorphize_association(str)
        if (match = str.match(/_of_([^_]+?)_type$/))
          [match.pre_match, Kernel.const_get(match.captures.first)]
        else
          [str, nil]
        end
      end
    end
  end
end