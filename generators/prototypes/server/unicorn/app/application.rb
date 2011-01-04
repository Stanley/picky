# encoding: utf-8
#
# TODO Adapt the generated example
#      (a library books finder) to what you need.
#
# Check the Wiki http://github.com/floere/picky/wiki for more options.
# Ask me or the google group if you have questions or specific requests.
#
class PickySearch < Application

  # Indexing: How text is indexed.
  #
  default_indexing removes_characters: /[^a-zA-Z0-9\s\/\-\"\&\.]/,
                   stopwords:          /\b(and|the|of|it|in|for)\b/,
                   splits_text_on:     /[\s\/\-\"\&\.]/

  # Querying: How query text is handled.
  #
  default_querying removes_characters: /[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/, # Picky needs control chars *"~: to pass through.
                   stopwords:          /\b(and|the|of|it|in|for)\b/,
                   splits_text_on:     /[\s\/\-\,\&]+/,

                   maximum_tokens: 5, # Amount of tokens passing into a query (5 = default).
                   substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

  # Define an index. Use a database etc. source?
  # See http://github.com/floere/picky/wiki/Sources-Configuration#sources
  #
  books_index = index :books, Sources::CSV.new(:title, :author, :year, file: 'app/library.csv')
  books_index.define_category :title,
                              similarity: Similarity::Phonetic.new(3), # Up to three similar title word indexed (default: No similarity).
                              partial: Partial::Substring.new(from: 1) # Indexes substrings upwards from character 1 (default: -3),
                                                                       # You'll find "picky" even when entering just a "p".
  books_index.define_category :author,
                              partial: Partial::Substring.new(from: 1)
  books_index.define_category :year,
                              partial: Partial::None.new # Partial substring searching on the year does not make
                                                         # much sense, neither does similarity.

  query_options = { :weights => { [:title, :author] => +3, [:title] => +1 } } # +/- points for ordered combinations.

  full_books = Query::Full.new books_index, query_options    # A Full query returns ids, combinations, and counts.
  live_books = Query::Live.new books_index, query_options    # A Live query does return all that Full returns, except ids.

  route %r{\A/books/full\Z} => full_books                    # Routing is simple: url_path_regexp => query
  route %r{\A/books/live\Z} => live_books                    # 

  # Note: You can pass a query multiple indexes and it will query in all of them.

end