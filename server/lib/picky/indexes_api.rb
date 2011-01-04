# Comfortable API convenience class, splits methods to indexes.
#
class IndexesAPI # :nodoc:all
  
  attr_reader :indexes, :index_mapping
  
  delegate :reload,
           :load_from_cache,
           :to => :@indexed
  
  delegate :check_caches,
           :find,
           :generate_cache_only,
           :generate_index_only,
           :index,
           :index_for_tests,
           :to => :@indexing
  
  def initialize
    @indexes = []
    @index_mapping = {}
    
    @indexed  = Indexed::Indexes.new
    @indexing = Indexing::Indexes.new
  end
  
  def register index
    self.indexes << index
    self.index_mapping[index.name] = index
    
    @indexing.register index.indexing
    @indexed.register  index.indexed
  end
  
  def [] name
    name = name.to_sym
    
    self.index_mapping[name]
  end
  
end