module Picky

  module Generators
  
    module Server

      # Generates a new Picky Unicorn Server Example.
      #
      # Example:
      #   > picky-generate unicorn_server my_lovely_unicorn
      #
      class Unicorn < Picky::Generators::Base
  
        def initialize identifier, name, *args
          super identifier, name, 'server/unicorn', *args
        end
  
        #
        #
        def generate
          exclaim "Setting up Picky Unicorn Server \"#{name}\"."
          create_target_directory
          copy_all_files expand_prototype_path('server/shared_unicorn')
          copy_all_files
          exclaim "\"#{name}\" is a great project name! Have fun :)\n"
          exclaim ""
          exclaim "Next steps:"
          exclaim "1. cd #{name}"
          exclaim "2. bundle install"
          exclaim "3. rake index"
          exclaim "4. rake start"
          exclaim "5. rake           # (optional) shows you where Picky needs input from you"
          exclaim "                  #            if you want to define your own search."
        end
  
      end
    
    end
  
  end
  
end