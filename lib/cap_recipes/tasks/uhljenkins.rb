# -*- coding: utf-8 -*-
Capistrano::Configuration.instance(true).load do |configuration|
  set :use_sudo, true

  _cset :deploy_to_parent, "/srv/applications"
  _cset :branch, "master"

  default_run_options[:pty] = true

  # this is capistrano's default location.
  # depending on the permissions of the server
  # you may need to create it and chown it over
  # to :user (e.g. chown -R robotuser:robotuser /u)
  set :deploy_to do
    "#{deploy_to_parent}/#{application}"
  end

  set :deploy_to_gitrepo do
    "#{deploy_to}/repo"
  end


  set :local_base_dir do
    "#{`pwd`}".strip
  end

  _cset :war_config, Array.new
  _cset :war_name, ""
  _cset :war_path, "not set.war"

  _cset :servers, ""
  _cset :deploy_to, ""

  set :local_git_dir do
    "/tmp/localgit_#{application}"
  end
  set :local_gitrepo do
    "#{local_git_dir}/#{application}"
  end

  role :app, :primary => true do
    servers.split(/[,\s]+/).collect do|s|
      unless s.include?(":")
        "#{s}:58422"
      else
        s
      end
    end
  end

  role :single, "1.1.1.1"

  namespace :uhljenkins do

    desc "setup remote and locate uhljenkins dir"
    task :setup do
      uhljenkins.setup_remote
      uhljenkins.setup_local
    end

    desc "setup remote uhljenkins dir"
    task :setup_remote do
      run clone_repository_command()
    end

    desc "setup locate uhljenkins dir"
    task :setup_local do
      system clone_repository_local_command()
    end

    desc "just pull current build version, doesn't add tag."
    task :pull do
      uhljenkins.setup_local

      system "cd #{local_gitrepo}; git checkout #{branch}; git fetch; git rebase origin/#{branch};"

      unless war_name.empty?
        puts "name=#{war_name}, war=#{war_path}"
        system update_repository_local_command(war_name, war_path)
      else
        if war_config.nil? or war_config.size == 0
          raise 'NO war_config'
        end
        war_config.each do |config|
          puts "name=#{config[:name]}, war=#{config[:war]}"
          system update_repository_local_command(config[:name], config[:war])
        end
      end

      build_msg = war_name.empty? ? "all" : war_name
      system "cd #{local_gitrepo}; git add .; git commit -m 'build for #{build_msg}'"

      # push tags and latest code
      system "cd #{local_gitrepo}; git push origin #{branch}"
      if $? != 0
        raise "git push failed"
      end

    end

    desc "tag build version. use -s tag=xxx to set tag's name"
    task :tag do
      uhljenkins.setup_local
      system "cd #{local_gitrepo}; git checkout #{branch}; git fetch; git rebase origin/#{branch};"

      tag_name = configuration[:tag] || configuration[:build_version]
      raise "NO tag. pls use -s tag=xxx set tag_name" if tag_name.nil?

      system "cd #{local_gitrepo}; git tag #{tag_name};"

      system "cd #{local_gitrepo}; git push origin #{branch} --tags"
      if $? != 0
        raise "git push --tags failed"
      end
    end

    desc "deploy. use -s tag=xxx to set tag's name, if NOT set tag, pull the repository's last version."
    task :deploy do
      tag_name = configuration[:tag] || configuration[:build_version]
      if tag_name.nil?
        # raise "NO tag. pls use -s tag=xxx set tag_name"
        run update_repository_remote_command(tag_name)
      else
        run pull_repository_remote_command(branch)
      end
    end

    desc "register servers and deploy_dir on CMDB"
    task :register_servers do
      version = build_version
      puts "version=#{version}, servers=#{servers}, deploy_dir=#{deploy_to}"
      CmdbService.start_deploy_with_server(cse_base, deploy_unit_code, deploy_stage, version.strip, servers, deploy_to)
    end

    desc "send deploy success info to CMDB"
    task :deploy_succ do
      CmdbService.complete_deploy(cse_base, deploy_unit_code, deploy_stage, true, "部署成功")
    end

    desc "send deploy failure info to CMDB"
    task :deploy_fail do
      CmdbService.complete_deploy(cse_base, deploy_unit_code, deploy_stage, false, "capistrano部署失败，撤销发布。")
    end


    def self.clone_repository_local_command
      [
       "if [ ! -e #{local_git_dir} ]",
       "then mkdir -p #{local_git_dir}",
       "cd #{local_git_dir}",
       "git clone #{repository} #{local_gitrepo}",
       "fi"
      ].join("; ")
    end


    def self.update_repository_local_command(name, war)
      unless war.start_with?('/')
        war_path = "#{local_base_dir}/#{war}"
      else
        war_path = war
      end
      [
       "cd #{local_gitrepo}",
       "if [ -e #{local_gitrepo}/#{name} ]",
       "then git rm -rf #{local_gitrepo}/#{name}",
       "fi",
       "mkdir -p #{local_gitrepo}/#{name}",
       "cd #{local_gitrepo}/#{name}",
       "jar -xf #{war_path}"
      ].join("; ")
    end

    def self.clone_repository_command
      [
       "if [ ! -e #{deploy_to_gitrepo} ]",
       "then sudo mkdir -p #{deploy_to}",
       "sudo chown #{user} #{deploy_to}",
       "cd #{deploy_to}",
       "git clone #{repository} #{deploy_to_gitrepo}",
       "fi"
      ].join("; ")
    end

    def self.update_repository_remote_command(tag_name)
      [
       # git reset --hard;git fetch;git reset --merge #{tag_name}
       "cd #{deploy_to_gitrepo}",
       "git reset --hard",
       "git fetch",
       "git reset --merge #{tag_name}",
      ].join("; ")
    end

    def self.pull_repository_remote_command(branch)
      [
       # git reset --hard;git fetch;git reset --merge #{tag_name}
       "cd #{deploy_to_gitrepo}",
       "git reset --hard",
       "git fetch",
       "git rebase origin/#{branch}",
      ].join("; ")
    end

  end

end
