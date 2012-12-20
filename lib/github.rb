require 'json'
class Github

  class PullRequest

    # Private: Creates the PullRequest objects in Github#pull_requests
    def initialize(github, url)
      @github = github
      @url = url
    end

    # Private: lazy load the json
    def json
      @json ||= JSON.load(`curl -H "Authorization: token #{@github.token}" --silent #{@url}`.chomp)
    end

    # Public: Return the pull request id / number
    def id
      json['number']
    end

    # Public: Has this pull requests been merged, yet?
    def merged?
      json['merged']
    end

    # Public: Is this pull request automatically mergeable?
    def mergeable?
      json['mergeable']
    end

    # Public: The merge_commit_sha of the pull request, i.e. what would the 
    #         SHA be if we merged this branch into master (or it's target)
    #
    # Returns a string (git SHA)
    def merge_commit_sha
      json['merge_commit_sha']
    end

    # Public: Returns the SHA of the pull request's HEAD
    #
    # Returns a string (git SHA)
    def head_sha
      json['head']['sha']
    end

  end


  # Public: Create an instance handling the status of a particular
  #         repo
  #
  # Arguments:
  #    token - an Oauth token string
  #    repo  - which repo to manage, e.g. "fac/freeagent"
  def initialize(token, repo)
    @token, @repo = token, repo
  end

  attr_reader :token

  # Public: Update the build state of a particular SHA in this repo
  # 
  # Arguments:
  #    sha         - the sha to update
  #    state       - the build state, one of "pending", "success", "failure", "error"
  #    description - a string description to attach
  #    url         - a URL to attach for more info
  def update_state(sha, state, description, url)
    request = JSON.dump({
      "state"       => state,
      "description" => description,
      "target_url"  => url
    })
    
    `curl -H "Authorization: token #{@token}" -XPOST --silent https://api.github.com/repos/#{@repo}/statuses/#{sha} -d '#{request}'`
  end

  # Public: Get all the pull requests on this repo
  #
  # Returns an array of Github::PullRequest objects
  def pull_requests
    JSON.load(`curl -H "Authorization: token #{@token}" --silent https://api.github.com/repos/#{@repo}/pulls?state=open`.chomp).map do |json|
      Github::PullRequest.new(self, json["url"])
    end
  end
end