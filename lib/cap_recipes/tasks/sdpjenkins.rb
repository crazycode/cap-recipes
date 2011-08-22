# -*- coding: utf-8 -*-
require "fileutils"

require File.expand_path(File.dirname(__FILE__) + '/utilities')
require File.expand_path(File.dirname(__FILE__) + '/cmdbutils')

include FileUtils

Capistrano::Configuration.instance(true).load do |configuration|

  # 为测试环境发布使用
  _cset :build_workspace, ""
  _cset :release_dir, ""
  _cset :release_pattern, "*.war"
  _cset :upload_dir, ""
  _cset :shell_commands, "cd #{upload_dir}; ls -all"

  namespace :sdpjenkins do

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

    desc "copy all war to specify dir"
    task :copy_to_dir do
      if build_workspace.empty?
        puts "Please specify the build_workspace dir, set :build_workspace, '/home/foo/project/code'"
        exit(1)
      end
      if release_dir.empty?
        puts "Please specify the release_dir, set :release_dir, '/home/foo/project/release'"
        exit(1)
      end

      unless File.directory?(build_workspace)
        puts "the build_workspace #{build_workspace} NOT exists!"
        exit(1)
      end

      unless File.directory?(release_dir)
        mkdir_p release_dir
      end

      files = []
      release_pattern.split(/[,;\s]+/).each do |pattern|
        files += Dir[File.join(build_workspace.split(/\\/), "**", pattern)]
      end

      files.each do |file|
        target_name = File.basename(file).gsub(/-((\d+)\.?)+(-SNAPSHOT)?/, "")
        cp file, "#{release_dir}/#{target_name}"
      end

    end

    desc "upload released file to remote hosts"
    task :upload_file do
      if upload_dir.empty?
        puts "Please specify the remote upload_dir, set :upload_dir, '/opt/applications/project/upload'"
        exit(1)
      end
      run "mkdir -p #{upload_dir}"
      Dir[File.join(release_dir.split(/\\/), "**")].each do |file|
        top.upload file, upload_dir, :via => :scp
      end
    end

    desc "execute commands from remote hosts"
    task :execute_commands do
      unless shell_commands.empty?
        run shell_commands
      end
    end

    desc "copy file, upload it, then execute commands"
    task :doall do
      copy_to_dir
      upload_file
      execute_commands
    end

  end
end
