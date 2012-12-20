require 'json'
class Github

  # Public: Create an instance handling the status of a particular
  #         repo
  #
  # Arguments:
  #    token - an Oauth token string
  #    repo  - which repo to manage, e.g. "fac/freeagent"
  def initialize(token, repo)
    @token, @repo = token, repo
  end

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
end