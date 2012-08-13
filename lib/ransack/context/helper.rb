module Ransack
  class Context
    module Helper
      def assoc_klass
        klass || found_assoc.klass
      end

      def remainder_association_name
        remainder.join('_')
      end        

      def found_assoc
        @found_assoc ||= get_association(assoc, klass)
      end
      alias_method :found_assoc?, :found_assoc

      def unpolymorphize
        @assoc, @poly_class = unpolymorphize_association(segments_name)
      end

      def segments_name
        segments.join('_')
      end

      def segments_remain?
        !found_assoc && segments.size > 0    
      end

      def segments
        @segments ||= str.split(/_/)
      end 

      def classifier(parent)
        Classifier.new parent
      end    
    end
  end
end