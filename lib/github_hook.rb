require 'sinatra/base'
require 'time'

class GithubHook < Sinatra::Base
  def self.parse_git
    # Parse hash and date from the git log command.
    sha1, date = `git log HEAD~1..HEAD --pretty=format:%h^%ci`.strip.split('^')
    set :commit_hash, sha1
    set :commit_date, Time.parse(date)
  end

  set(:autopull) { production? }
  parse_git

  before do
    cache_control :public, :must_revalidate
    etag settings.commit_hash
    last_modified settings.commit_date
  end

  post '/update' do
    settings.parse_git

    app.settings.reset!
    load app.settings.app_file

    content_type :txt
    # Pipe stderr to stdout to make
      # sure we display everything.
    if settings.autopull?
      `git pull 2>&1`
    else
      "ok"
    end
  end
end

# The above middleware will reload our application whenever /update 
# is being requested. We can use that when setting up a hook later on.

# Since articles Dir will not change unless we push an update upstream, 
# there is no reason to read them from disk more often than that. 
# The general idea is to spend as little time as possible in the 
# Ruby process when a request comes in. We will look into how to 
# reduce that time even further and how to keep requests from 
# reaching the Ruby process in the first place by setting the proper 
# HTTP headers.