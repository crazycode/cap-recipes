# -*- coding: utf-8 -*-
require "fileutils"

require 'cap_recipes/tasks/gitdeploy'
require 'cap_recipes/tasks/tomcat'

require File.expand_path(File.dirname(__FILE__) + '/utilities')
require File.expand_path(File.dirname(__FILE__) + '/cmdbutils')

Capistrano::Configuration.instance(true).load do |configuration|

  set :use_sudo, true

  set :cse_base, "http://10.241.14.166:8080/cse"
  set :deploy_unit_code, ""
  set :deploy_stage, "development"

  set :deploy_id_file, ".deploy_id"
  set :tag, ""

  role :app do
    CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
  end

  namespace :cmdb do


    task :start do
      if File.exists? deploy_id_file
        puts "Previous Deploy NOT Complete, please run 'cap cmdb:failback' first."
        exit(1)
      end

      deploy_id = CmdbService.start_deploy("#{cse_base}", deploy_unit_code, deploy_stage, tag)

      open(deploy_id_file, 'w') do |f|
        f.write deploy_id
      end
    end

    desc "set current deploy FAILBACK!"
    task :failback do
      deploy_id = CmdbService.get_deploy_id(deploy_id_file)
      unless deploy_id.nil?
        CmdbService.complete_deploy(cse_base, deploy_unit_code, deploy_id, false, "capistrano部署失败，撤销发布")
      end
    end

    desc "set current deploy success DONE!"
    task :done do
      deploy_id = CmdbService.get_deploy_id(deploy_id_file)
      puts "deploy_id=#{deploy_id}, file=#{deploy_id_file}"
      CmdbService.complete_deploy(cse_base, deploy_unit_code, deploy_id, true, "通过capistrano部署成功")
      File.delete deploy_id_file
    end

    desc "deploy to tomcat"
    task :deploy_to_tomcat do
      cmdb.start
      deploy_id = CmdbService.get_deploy_id(deploy_id_file) || CmdbService.start_deploy("#{cse_base}", deploy_unit_code, deploy_stage, tag)
      puts "deploy_id=#{deploy_id}"

      gitdeploy.deploy
      tomcat.restart

      cmdb.done
    end

  end
end
