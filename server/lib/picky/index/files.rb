module Index
  
  class Files
    
    attr_reader :bundle_name
    attr_reader :prepared, :index, :weights, :similarity, :configuration
    
    delegate :index_name, :category_name, :to => :@config
    
    def initialize bundle_name, config
      @bundle_name = bundle_name
      @config      = config
      
      # Note: We marshal the similarity, as the
      #       Yajl json lib cannot load symbolized
      #       values, just keys.
      #
      @prepared      = File::Text.new    config.prepared_index_path
      @index         = File::JSON.new    config.index_path(bundle_name, :index)
      @weights       = File::JSON.new    config.index_path(bundle_name, :weights)
      @similarity    = File::Marshal.new config.index_path(bundle_name, :similarity)
      @configuration = File::JSON.new    config.index_path(bundle_name, :configuration)
    end
    
    # Delegators.
    #
    
    # Retrieving data.
    #
    def retrieve &block
      prepared.retrieve &block
    end
    
    # Dumping.
    #
    def dump_index index_hash
      index.dump index_hash
    end
    def dump_weights weights_hash
      weights.dump weights_hash
    end
    def dump_similarity similarity_hash
      similarity.dump similarity_hash
    end
    def dump_configuration configuration_hash
      configuration.dump configuration_hash
    end
    
    # Loading.
    #
    def load_index
      index.load
    end
    def load_similarity
      similarity.load
    end
    def load_weights
      weights.load
    end
    def load_configuration
      configuration.load
    end
    
    # Cache ok?
    #
    def index_cache_ok?
      index.cache_ok?
    end
    def similarity_cache_ok?
      similarity.cache_ok?
    end
    def weights_cache_ok?
      weights.cache_ok?
    end
    
    # Cache small?
    #
    def index_cache_small?
      index.cache_small?
    end
    def similarity_cache_small?
      similarity.cache_small?
    end
    def weights_cache_small?
      weights.cache_small?
    end
    
    # Copies the indexes to the "backup" directory.
    #
    def backup
      index.backup
      weights.backup
      similarity.backup
      configuration.backup
    end
    
    # Restores the indexes from the "backup" directory.
    #
    def restore
      index.restore
      weights.restore
      similarity.restore
      configuration.restore
    end
    
    
    # Delete all index files.
    #
    def delete
      index.delete
      weights.delete
      similarity.delete
      configuration.delete
    end
    
  end
  
end