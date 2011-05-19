# encoding: utf-8
#
module Internals

  module Generators

    module Similarity

      # It's actually a combination of soundex
      # and Levenshtein.
      #
      # It uses the soundex to get similar words
      # and ranks them using the levenshtein.
      #
      class Soundex < Phonetic

        # Encodes the given symbol.
        #
        # Returns a symbol.
        #
        def encoded sym
          code = Text::Soundex.soundex sym.to_s
          code.to_sym if code
        end

      end

    end

  end

end