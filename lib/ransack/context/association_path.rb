module Ransack
  class Context
    class AssociationPath
      attr_reader :base, :str, :path, :association_parts

      def initialize str, base = @base
        @base = klassify(base)
        @str ||= ''
        @path = []
        clear_association_parts
      end

      # TODO: Refactor - see same pattern in other places, fx AssociationContext
      def resolve
        # LOOKS LIKE VERY FAMILIAR PATTERN!!!
        while segments_remain_to_resolve? do
          unpolymorphize        
          handle_assoc if found_assoc?
        end
        path.join('_')
      end

      protected

      def handle_assoc
        add_path association_parts
        clear_association_parts!
        @base = klassify(klass || found_assoc)
      end        

      def found_assoc
        @found_assoc ||= get_association(assoc, klass)
      end
      alias_method :found_assoc?, :found_assoc

      def unpolymorphize 
        @assoc, @poly_class = unpolymorphize_association(association_parts.join('_'))
      end

      # WTF!? please split each boolean statement into a meaningful method here!
      def segments_remain_to_resolve?
        segments.size > 0 && !base.columns_hash[segments.join('_')] && association_parts << segments.shift
      end

      def add_path association_parts
        @path += association_parts
      end

      def clear_association_parts!
        @association_parts = []
      end

      def segments
        @segments ||= str.split(/_/)
      end

      include Polymorph
    end
  end
end