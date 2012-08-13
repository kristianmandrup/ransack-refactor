module Ransack::Adapters::ActiveRecord
  class Associater
    attr_reader :klass

    def initialize str, parent, auth_object
      @klass = klassify parent
      @str = str
    end

    def associate
      ransackable_association? && association_match?      
    end

    def  association_match?
      klass.reflect_on_all_associations.detect {|a| a.name.to_s == str}
    end

    def ransackable_association?
      klass.ransackable_associations(auth_object).include? str
    end      
  end
end

