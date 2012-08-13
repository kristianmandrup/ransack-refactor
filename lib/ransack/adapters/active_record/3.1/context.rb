require 'ransack/context'
require 'polyamorous'

module Ransack::Adapters::ActiveRecord
  class Context < ::Ransack::Context    
    def initialize(object, options = {})
      super
      @options = options 
    end

    def evaluate search, opts = {}
      evaluator(search, options).evaluate
    end

    def evaluator search, options = {}
      @evaluator ||= Evaluater.new search, options
    end

    def visitor
      @visitor ||= Arel::Visitors.visitor_for @engine
    end

    def attribute_method?(str, klass = @klass)
      puts "attribute_method?: #{str}, #{klass}"
      return true if ransackable_attribute?(str, klass)
      return association_context(segments).resolve
    end

    def association_context segment
      AssociationContext.new(segments)
    end

    private

    def classifier(parent)
      Classifier.new parent
    end    

    def get_parent_and_attribute_name(str, parent = @base)
      puts "get_parent_and_attribute_name: #{str}, #{parent}"  
      return [parent, nil] if ransackable_attribute?(str, parent_clazz)
      parent_context(str, parent_clazz).resolve
    end

    def parent_clazz
      classifier(parent).classify
    end

    def parent_context str, klass
      ParentContext.new str, klass
    end

    def join_dependency
      @join_dependency ||= JoinDependency.new object, options
    end
  end
end
