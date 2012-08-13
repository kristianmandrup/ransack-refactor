module Ransack::Adapters::ActiveRecord
  class AssociationContext
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
      do_loop
    end

    protected

    def do_loop
      while segments_remain_to_resolve? do
        unpolymorphize        
        break true if found_assoc && attribute_association?
        false
      end
    end

    def segments_remain_to_resolve?
      !found_assoc && remainder.unshift(segments.pop) && segments.size > 0      
    end

    def attribute_association?
      self.new(remainder_association_name, association_class).resolve
    end

    def remainder_association_name
      remainder.join('_')
    end

    def association_class 
      poly_class || found_assoc.klass
    end

    def found_assoc
      @found_assoc ||= get_association(assoc, klass)
    end
    alias_method :found_assoc?, :found_assoc

    def unpolymorphize
      @assoc, @poly_class = unpolymorphize_association(segments.join('_'))
    end

    def get_association(str, parent = @base)
      puts "get_association: #{str}, #{parent}"
      klass = classifier(parent).classify
      ransackable_association?(str, klass) &&
      klass.reflect_on_all_associations.detect {|a| a.name.to_s == str}
    end    

    def classifier(parent)
      Classifier.new parent
    end

    def ransackable_association?
      klass.ransackable_associations(auth_object).include? str
    end

    def ransackable_associations(auth_object = nil)
      reflect_on_all_associations.map {|a| a.name.to_s}
    end    

    def unpolymorphize_association
      if (match = str.match(/_of_([^_]+?)_type$/))
        [match.pre_match, Kernel.const_get(match.captures.first)]
      else
        [str, nil]
      end
    end 

    def ransackable_attribute?
      klass.ransackable_attributes(auth_object).include? str
    end    
  end
end
