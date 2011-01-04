# encoding: utf-8
#
module Indexed
  
  # TODO Spec
  #
  module Wrappers
    
    # This index combines an exact and partial index.
    # It serves to order the results such that exact hits are found first.
    #
    # TODO Need to use the right subtokens. Bake in?
    #
    class ExactFirst < Bundle
      
      delegate :similar,
               :identifier,
               :name,
               :to => :@exact
      delegate :index,
               :category,
               :weight,
               :generate_partial_from,
               :generate_caches_from_memory,
               :generate_derived,
               :dump,
               :load,
               :to => :@partial
      
      def initialize category
        @exact   = category.exact
        @partial = category.partial
      end
      
      def self.wrap index_or_category
        if index_or_category.respond_to? :categories
          wrap_each_of index_or_category.categories
          index_or_category
        else
          new index_or_category
        end
      end
      # TODO Do not extract categories!
      #
      def self.wrap_each_of categories
        categories.categories.collect! { |category| new(category) }
      end
      
      def ids text
        @exact.ids(text) + @partial.ids(text)
      end
      
      def weight text
        [@exact.weight(text) || 0, @partial.weight(text) || 0].max
      end
      
    end
    
  end
  
end