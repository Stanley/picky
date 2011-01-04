# Ruby Search Client Frontend for the Picky search engine.
#
# === Usage
#
# ==== 1. Set up search clients.
# 
#   # Create search client instances e.g. in your development.rb, production.rb etc.
#   #
#   # Use the right host, port where your Picky server runs. Then, choose a URL path as defined
#   # in your <tt>app/application.rb</tt> in the server.
#   #
#   FullBooks = Picky::Client::Full.new :host => 'localhost', :port => 8080, :path => '/books/full'
#   LiveBooks = Picky::Client::Live.new :host => 'localhost', :port => 8080, :path => '/books/live'
#
# ==== 2. Get results.
#
#   # Then, in your search methods, call #search.
#   #
#   # You will get back a Hash with categorized results.
#   # 
#   results = FullBooks.search 'my query', :offset => 10
#   
# ==== 3. Work with the results.
#
#   # To make the Hash more useful, extend it with a few convenience methods.
#   # See Picky::Convenience.
#   #
#   results.extend Picky::Convenience
#
#   # One of the added Methods is:
#   #   populate_with(ModelThatSupportsFind, &optional_block_where_you_get_model_instance_and_you_can_render)
#   # This adds the rendered models to the results Hash.
#   #
#   results.populate_with Book do |book|
#     book.to_s
#   end
#   
# ==== 4. Last step is encoding it back into JSON.
#
#   # Encode the results in JSON and return it to the Javascript Client (or your frontend). 
#   #
#   ActiveSupport::JSON.encode results
#
# Note: The client might be rewritten such that instead of an http request it connects through tcp/0mq.
#
require 'net/http'

module Picky
  
  module Client

    class Base

      attr_accessor :host, :port, :path

      def initialize options = {}
        options = default_configuration.merge options

        @host = options[:host]
        @port = options[:port]
        @path = options[:path]
      end
      def default_configuration
        {}
      end
      def self.default_configuration options = {}
        define_method :default_configuration do
          options
        end
      end
      def default_params
        {}
      end
      def self.default_params options = {}
        options.stringify_keys! if options.respond_to?(:stringify_keys!)
        define_method :default_params do
          options
        end
      end
      
      # Merges the given params, overriding the defaults.
      #
      def defaultize params = {}
        default_params.merge params
      end
      
      # Searches the index. Use this method.
      #
      # Returns a hash. Extend with Convenience.
      #
      def search query, params = {}
        return {} unless query && !query.empty?
        
        send_search params.merge :query => query
      end
      
      # Sends a search to the configured address.
      #
      def send_search params = {}
        params = defaultize params
        Net::HTTP.get self.host, "#{self.path}?#{params.to_query}", self.port
      end

    end

    class Full < Base
      default_configuration :host => 'localhost', :port => 8080, :path => '/searches/full'
      
      @@parser_options = { :symbolize_keys => true }
      def send_search params = {}                                                                                                                                 
        Yajl::Parser.parse super(params), @@parser_options
      end
    end

    class Live < Base
      default_configuration :host => 'localhost', :port => 8080, :path => '/searches/live'
    end

  end
end

# Extend hash with to_query method.
#
begin
  require 'active_support/core_ext/object/to_query'
rescue LoadError
  
end
class Hash
  def to_query namespace = nil
    collect do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
end