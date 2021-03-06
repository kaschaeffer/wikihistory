require 'uri'
require 'open-uri'
require 'active_support/core_ext/hash'
require 'json'

class WikiApi
  def initialize
    @base_url = "http://en.wikipedia.org/w/api.php"
  end

  def fetch_all_results(title)
    results = []
    page = 1
    next_page ||= nil
    loop do
      puts "Fetching page #{page} of the results..."
      puts "Next page: #{next_page}"
      result = query(title, rvcontinue: next_page)
      results << result
      page += 1
      break if !result.key?('query-continue')
      next_page = result['query-continue']['revisions']['rvcontinue']
    end
    results
  end

  def get_next_page result
    #TODO
  end

  # Maybe this shouldn't have so many defaults hardcoded in...
  def query(title, options={})
    # format the query string
    default_options = {
      :prop => "revisions",
      :format => "json",
      # :rvlimit => "max",
      :rvlimit => "max",
      :titles => title,
      # :rvprop => ["ids", "flags", "timestamp", "user", "userid",
      #              "comment", "size", "content"]
      :rvprop => ["timestamp", "user", "userid", "flags", "ids",
                   "comment", "size", "tags"],
      # :rvcontinue => 415180915
      # for now going to ignore content altogether...
      # :rvdiffto => "cur",
      # :rvdir => "newer"
    }
    puts "options = #{options.inspect}"
    options = default_options.merge(options)

    query_url = "#{@base_url}?action=query"
    options.each do |option, arg|
      # ignore nil values
      if arg.nil?
        next
      end

      if arg.class == String || arg.class == Fixnum
        query_url << "&#{option}=#{arg}"
      elsif arg.class == Array
        formatted_array = arg.join("|")
        query_url << "&#{option}=#{formatted_array}"
      else
        raise TypeError, "#{arg.class} cannot be parsed into a query string"
      end
    end

    puts "Querying the API at"
    puts query_url

    # Need to escale the URI because of "|" symbols
    enc_query_url = URI.escape(query_url)

    response = open(enc_query_url).read
    parsed_response = JSON.parse(response)
  end

  def query_export_page title
    # this timed out after approximately a minute
    # seems like the other method will be faster/better
    query_url = "http://en.wikipedia.org/w/index.php?title=Special:Export&pages=#{title}&history"

    response = open(query_url).read
    session = Hash.from_xml(response)
  end
end

if __FILE__ == $PROGRAM_NAME
  wiki_api = WikiApi.new

  einstein = wiki_api.query("Albert_Einstein")

  puts einstein.keys

  # this returns a hash with key "rvcontinue"
  # which can be passed back in on another query to get further results

  # puts einstein['query'].inspect
  # puts "Number of revisions returned: #{revisions.count}"

  # TODO probably want an intelligent way to pull out this page #...
  example_revisions = einstein["query"]["pages"]["736"]["revisions"]

  puts JSON.pretty_generate(example_revisions)

  # content_revision = example_revision["content"]

  # puts "-----------------------------"
  # puts "-     query                 -"
  # puts "-----------------------------"
  # puts example_revision["query"]

  # puts "-----------------------------"
  # puts "-     contentformat         -"
  # puts "-----------------------------"
  # puts example_revision["contentformat"]

  # puts "-----------------------------"
  # puts "-     contentmodel          -"
  # puts "-----------------------------"
  # puts example_revision["contentmodel"]
  #
  # Note: can page through all the responses... using "continue"
  # or, can use export XML option to get bulk response all at once
  puts einstein["query-continue"]

  # *********************************************************
  # *** alternate bulk XML download                       ***
  # *********************************************************

  # einstein = wiki_api.query_export_page("Albert_Einstein")
  # puts einstein['mediawiki']['page'].keys

  einstein = wiki_api.fetch_all_results("Albert_Einstein")

  puts einstein.count
end
