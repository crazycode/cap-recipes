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
      CmdbService.do_deploy(cse_base, deploy_unit_code, deploy_stage, version.strip) do
        gitdeploy.deploy
        tomcat.restart
      end
    end
  end
end
