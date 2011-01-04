module Indexing
  
  class Index
    
    attr_reader :name, :source, :categories, :after_indexing
    
    # Delegators for indexing.
    #
    delegate :connect_backend,
             :to => :source
             
    delegate :index,
             :cache,
             :generate_caches,
             :backup_caches,
             :restore_caches,
             :check_caches,
             :clear_caches,
             :create_directory_structure,
             :to => :categories
    
    def initialize name, source, options = {}
      @name   = name
      @source = source
      
      @after_indexing = options[:after_indexing]
      
      @categories = Categories.new
    end
    
    # TODO Spec. Doc.
    #
    def define_category category_name, options = {}
      options = default_category_options.merge options
      
      new_category = Category.new category_name, self, options
      categories << new_category
      new_category
    end
    
    # By default, the category uses the index's source.
    #
    def default_category_options
      { :source => @source }
    end
    
    # Indexing.
    #
    def take_snapshot
      source.take_snapshot self
    end
    
  end
  
end