$KCODE = 'UTF-8' if RUBY_VERSION < '1.9.0'

require 'rubygems'

begin
  require 'yajl'
  JSON = Yajl::Parser
rescue LoadError
  begin
    require 'json'
  rescue LoadError
    puts " Yajl gem missing!\nYou need to:\n1. Add the following line to Gemfile:\ngem 'yajl'\n1b. Or if you do not use MRI:\ngem 'json'\n2. Then, run:\nbundle update\n"
    exit 1
  end
end

dir = File.dirname __FILE__
require File.expand_path('picky-client/client', dir)
require File.expand_path('picky-client/convenience', dir)
require File.expand_path('picky-client/helper', dir)
