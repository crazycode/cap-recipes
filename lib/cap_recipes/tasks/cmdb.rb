require "net/http"
require "uri"
require "json"

require 'cap_recipes/tasks/gitdeploy'
require File.expand_path(File.dirname(__FILE__) + '/http')

class CmdbService

  def self.get_app_role(cse_base, unit_code, stage)
    url = "#{cse_base}/deploy/get-server.do?deployUnitCode=#{unit_code}&stage=#{stage}"
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body

    # we convert the returned JSON data to native Ruby
    # data structure - a hash
    result = JSON.parse(data)

    # if the hash has 'Error' as a key, we raise an error
    if !result.has_key? 'success'
      raise "web service error"
    end
    return result
  end

end


Capistrano::Configuration.instance(true).load do |configuration|
  set :use_sudo, true

  set :cse_base, "http://10.241.14.166:8080/cse"
  set :deploy_unit_code, ""
  set :deploy_stage, "development"

  namespace :cmdb do

    desc "start cmdb deploy"
    task :start do
      s = CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
      puts "s=#{s}"
    end

  end
end
