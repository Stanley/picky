# encoding: utf-8
#
require 'fileutils'

module Picky
  
  module Client
  
    # Thrown when no generator for the command
    #   picky <command> <options>
    # is found.
    #
    class NoGeneratorException < Exception; end
  
    # This is a very simple project generator.
    # Not at all like Padrino's or Rails'.
    # (No diss, just by way of a faster explanation)
    #
    # Basically copies a prototype project into a newly generated directory.
    #
    class Generator
    
      attr_reader :types
    
      def initialize
        @types = {
          :sinatra => Project
          # :rails => Project
        }
      end
    
      # Run the generators with this command.
      #
      # This will "route" the commands to the right specific generator.
      #
      def generate args
        generator = generator_for *args
        generator.generate
      end
    
      #
      #
      def generator_for identifier, *args
        generator_class = types[identifier.to_sym]
        raise NoGeneratorException unless generator_class
        generator_for_class generator_class, identifier, *args
      end
    
      #
      #
      def generator_for_class klass, *args
        klass.new *args
      end
    
      # Generates a new Picky project.
      #
      # Example:
      #   > picky project my_lovely_project
      #
      class Project
      
        attr_reader :name, :prototype_project_basedir
      
        def initialize identifier, name, *args
          @name = name
          @prototype_project_basedir = File.expand_path "../../../#{identifier}_prototype", __FILE__
        end
      
        #
        #
        def generate
          exclaim "Setting up Picky project \"#{name}\"."
          create_target_directory
          copy_all_files
          exclaim "\"#{name}\" is a great project name! Have fun :)\n"
          exclaim ""
          exclaim "Next steps:"
          exclaim "cd #{name}"
          exclaim "bundle install"
          exclaim "unicorn -p 3000 # (optional) Or use your favorite web server."
          exclaim ""
        end
      
        #
        #
        def create_target_directory
          if File.exists?(target_directory)
            exists target_directory
          else
            FileUtils.mkdir target_directory
            created target_directory
          end
        end
      
        #
        #
        def copy_all_files
          all_prototype_files.each do |filename|
            next if filename.match(/\.textile$/)
            copy_single_file filename
          end
        end
      
        #
        #
        def target_filename_for filename
          filename.gsub(%r{#{prototype_project_basedir}}, target_directory)
        end
        #
        #
        def copy_single_file filename
          target = target_filename_for filename
          if File.exists? target
            exists target
          else
            smart_copy filename, target
          end
        end
      
        # Well, "smart" ;)
        #
        def smart_copy filename, target
          # p "Trying to copy #{filename} -> #{target}"
          if File.directory?(filename)
            FileUtils.mkdir_p File.dirname(target)
          else
            FileUtils.copy_file filename, target 
          end
          created target
        rescue Errno::EEXIST
          # p "EEXIST #{filename} -> #{target}"
          exists target
        rescue Errno::ENOENT => e
          # p "ENOENT #{filename} -> #{target}"
          if File.exists? filename
            FileUtils.mkdir_p File.dirname(target)
            retry
          else
            raise e
          end
        end
      
        #
        #
        def all_prototype_files
          Dir[File.join(prototype_project_basedir, '**', '*')]
        end
      
        #
        #
        def target_directory
          File.expand_path name, Dir.pwd
        end
      
        def created entry
          exclaim "#{entry} \x1b[32mcreated\x1b[m."
        end
      
        def exists entry
          exclaim "#{entry} \x1b[31mexists\x1b[m, skipping."
        end
      
        # TODO Remove?
        #
        def exclaim something
          puts something
        end
      
      end
      
    end
    
  end
  
end
