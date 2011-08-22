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

  # role :app, :primary => true do
  #   CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
  # end

  role :single, "1.1.1.1"

  namespace :sdpjenkins do

    desc "copy all war to specify dir"
    task :copy_to_dir, :roles => :app do
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
    task :upload_file, :roles => :app do
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
    task :execute_commands, :roles => :app do
      unless shell_commands.empty?
        run shell_commands
      end
    end

    desc "copy file, upload it, then execute commands"
    task :doall, :roles => :single do
      codes = deploy_unit_code.split(/[,;\s]+/)
      deploy_hash = Hash.new
      codes.each {|code| deploy_hash[code] = CmdbService.start_deploy(cse_base, code, deploy_stage, tag) }

      begin
        copy_to_dir
        upload_file
        execute_commands
        deploy_hash.each {|code, deployid| CmdbService.complete_deploy(cse_base, code, deployid, true, "通过capistrano部署成功") }
      rescue Exception => e
        deploy_hash.each {|code, deployid| CmdbService.complete_deploy(cse_base, code, deployid, false, "capistrano部署失败，撤销发布，原因：#{e.message}") }
      end

    end

  end
end
