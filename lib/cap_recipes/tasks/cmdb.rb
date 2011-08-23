# -*- coding: utf-8 -*-
require "fileutils"

require 'cap_recipes/tasks/gitdeploy'
require 'cap_recipes/tasks/tomcat'

require File.expand_path(File.dirname(__FILE__) + '/utilities')
require File.expand_path(File.dirname(__FILE__) + '/cmdbutils')

Capistrano::Configuration.instance(true).load do |configuration|

  set :use_sudo, true

  _cset :cse_base, "http://cmdb.shengpayops.com/cse"
  _cset :deploy_unit_code, ""
  _cset :deploy_stage, "development"

  _cset :build_version, ""

  role :app, :primary => true do
    CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
  end
  role :single, "1.1.1.1"

  namespace :cmdb do

    desc "deploy to tomcat"
    task :deploy_to_tomcat, :roles => :single do
      codes = deploy_unit_code.split(/[,;\s]+/)
      deploy_hash = Hash.new
      codes.each {|code| deploy_hash[code] = CmdbService.start_deploy(cse_base, code, deploy_stage, build_version) }
      begin
        gitdeploy.deploy
        tomcat.restart
        deploy_hash.each {|code, deployid| CmdbService.complete_deploy(cse_base, code, deployid, true, "通过capistrano部署成功") }
      rescue Exception => e
        deploy_hash.each {|code, deployid| CmdbService.complete_deploy(cse_base, code, deployid, false, "capistrano部署失败，撤销发布，原因：#{e.message}") }
      end
    end

  end
end
