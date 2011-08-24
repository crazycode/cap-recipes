# -*- coding: utf-8 -*-
require "fileutils"

require File.expand_path(File.dirname(__FILE__) + '/utilities')
require File.expand_path(File.dirname(__FILE__) + '/cmdbutils')

include FileUtils

Capistrano::Configuration.instance(true).load do |configuration|

  set :use_sudo, true

  _cset :cse_base, "http://cmdb.shengpayops.com/cse"
  _cset :deploy_unit_code, ""
  _cset :deploy_stage, "development"

  # 为测试环境发布使用
  _cset :build_workspace, ""
  _cset :release_dir, ""
  _cset :release_pattern, "*.war"
  _cset :upload_dir, ""
  _cset :shell_commands, "cd #{upload_dir}; ls -all"
  _cset :build_version, ""

  role :app, :primary => true do
    CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
  end

  role :single, "1.1.1.1"

  namespace :sdpjenkins do

    desc "copy all war to specify dir"
    task :copy_release_file, :roles => :app do
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

      system "echo \"#{build_version}\" >> #{release_dir}/version.txt"

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

    desc "upload release file, then execute commands"
    task :deploy, :roles => :single do
      version = build_version
      if version.empty? && File.exists?("#{release_dir}/version.txt")
        version = File.open("#{release_dir}/version.txt") { |f| f.extend(Enumerable).inject { |_,ln| ln } }
      end
      puts "version=#{version}"

      CmdbService.do_deploy(cse_base, deploy_unit_code, deploy_stage, version.strip) do
        upload_file
        execute_commands
      end
    end

  end
end
