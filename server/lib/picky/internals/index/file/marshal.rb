module Internals

  module Index
  
    module File
    
      # Index data in the Ruby Marshal format.
      #
      class Marshal < Basic
      
        # Uses the extension "dump".
        #
        def extension
          :dump
        end
        # Loads the index hash from marshal format.
        #
        def load
          ::Marshal.load ::File.open(cache_path, 'r:binary')
        end
        # Dumps the index hash in marshal format.
        #
        def dump hash
          hash.dump_marshalled cache_path
        end
        # A marshal file does not provide retrieve functionality.
        #
        def retrieve
          raise "Can't retrieve from marshalled file. Use text file."
        end
      
      end
    
    end
  
  end
  
end