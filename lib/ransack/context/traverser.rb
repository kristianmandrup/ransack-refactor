module Ransack
  class Context
    class Traverser
      include Ransack::Context::Helper

      attr_reader :str, :base

      def initialize str, base
        @str  = str
        @base = base
      end
        
      # Recursive traversing!
      # Create separate class for this!
      def traverse
        @str ||= ''
        handle_segments if segments.size > 0
        klassify(base)
      end

      protected

      # ONCE MORE SAME PATTERN!
      def handle_segments
        remainder = []
        found_assoc = nil
        do_loop
        raise UntraversableAssociationError, "No association matches #{str}" unless found_assoc
      end     

      def do_loop
        while segments_remain? do
          # Strip the _of_Model_type text from the association name, but hold
          # onto it in klass, for use as the next base
          unpolymorphize
          # recurse traverse!
          @base = Traverser.new(remainder_association_name, assoc_klass).traverse if found_assoc?
          remainder.unshift segments.pop
        end
      end        
    end
  end
end