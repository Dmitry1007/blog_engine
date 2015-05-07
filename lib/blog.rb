require 'sinatra/base'
# require 'github_hook'
require 'ostruct'
require 'time'
require 'yaml'

class Blog < Sinatra::Base
  # use GithubHook

  set :root, File.expand_path('../../', __FILE__)
  # File.expand_path('../../, __FILE__) = "/Users/Dmitry/sinatra"
  # root = "/Users/Dmitry/sinatra/blog_engine"
  
  set :articles, []
  set :app_file, __FILE__ # => "lib/blog.rb"

  # loop through all the article files
  Dir.glob "#{root}/articles/*" do |file|
    # file = "/Users/Dmitry/sinatra/blog_engine/articles/updated.md"
    
    # parse meta data and content from file
    meta, content   = File.read(file).split("\n\n", 2)
    # generate a metadata object
    article         = OpenStruct.new YAML.load(meta)
    # convert the date to a time object
    article.date    = Time.parse article.date.to_s
    # add the content
    article.content = content
    
    article.slug    = File.basename(file, '.md')
    # = "updated"

    get "/#{article.slug}" do
      erb :post, :locals => { :article => article }
    end
    # = [/\A\/updated\z/, [], [],
    #<Proc:0x007ff03b262e28@/Users/Dmitry/.rvm/gems/ruby-2.1.5/gems/sinatra-1.4.6/lib/sinatra/base.rb:1610>]

    # Add article to list of articles
    articles << article
  end
  # Sort articles by date, display new articles first
  articles.sort_by! { |article| article.date }
  articles.reverse!

  # defining and ERB template using inline approach
  get '/' do
    erb :index
  end
  # = [/\A\/\z/, [], [],
  #<Proc:0x007f9c6a260508@/Users/Dmitry/.rvm/gems/ruby-2.1.5/gems/sinatra-1.4.6/lib/sinatra/base.rb:1610>]
end
# \A = Start of string, \z = End of string

