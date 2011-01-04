module Picky
  
  # A very simple CLI selector.
  #
  class CLI # :nodoc:all
    
    # Execute a command.
    #
    # Note: By default, help is displayed. I.e. when no command is given.
    #
    def execute selector = nil, *args
      executor_class, *params = executor_class_for selector
      executor = executor_class.new
      executor.execute selector, args, params
    end
    def executor_class_for selector = nil
      selector && @@mapping[selector.to_sym] || [Help]
    end
    
    class Base
      def usage name, params
        puts "Usage\n  picky #{name} #{params_to_s(params)}"
      end
      def params_to_s params
        params.map { |param| "<#{param}>" }.join(' ') if params
      end
    end
    class Statistics < Base
      def execute name, args, params
        relative_log_file            = args.shift
        port                         = args.shift
        
        usage(name, params) || exit(1) unless relative_log_file
        
        ENV['PICKY_LOG_FILE']        = File.expand_path relative_log_file  
        ENV['PICKY_STATISTICS_PORT'] = port
        
        begin
          require 'picky-statistics'
        rescue LoadError => e
          require 'picky/extensions/object'
          puts_gem_missing 'picky-statistics', 'the Picky statistics'
          exit 1
        end
        
        require 'picky-statistics/application/app'
      end
    end
    class Generate < Base
      def execute name, args, params
        system "picky-generate #{args.join(' ')}"
      end
    end
    class Help < Base
      # Displays usage information.
      #
      def execute name, args, params
        commands = Picky::CLI.mapping.map do |command, object_and_params|
          _, *params = object_and_params
          "  picky #{command} #{params_to_s(params)}"
        end.join(?\n)
        
        puts "Possible commands:\n" + commands
      end
    end
    
    # Maps commands to the other gem's command.
    #
    @@mapping = {
      :generate => [Generate, 'sinatra_client | unicorn_server | empty_unicorn_server', 'app_directory_name (optional)'],
      :help     => [Help],
      :stats    => [Statistics, 'logfile, e.g. log/search.log', 'port (optional)']
    }
    def self.mapping
      @@mapping
    end
    
  end
  
end