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
    "#{deploy_to}/gitrepo"
  end


  set :local_base_dir do
    "#{`pwd`}".strip
  end

  _cset :war_config, Array.new


  set :local_git_dir do
    "/tmp/localgit_#{application}"
  end
  set :local_gitrepo do
    "#{local_git_dir}/local_gitrepo"
  end

  namespace :gitdeploy do

    desc "setup remote and locate gitdeploy dir"
    task :setup do
      gitdeploy.setup_remote
      gitdeploy.setup_local
    end

    desc "setup remote gitdeploy dir"
    task :setup_remote do
      run clone_repository_command()
    end

    desc "setup locate gitdeploy dir"
    task :setup_local do
      system clone_repository_local_command()
    end

    desc "tag build version. use -s tag=xxx to set tag's name"
    task :tag do
      gitdeploy.setup_local

      tag_name = configuration[:tag]
      if tag_name.nil?
        rails "NO tag. pls use -s tag=xxx set tag_name"
      end

      if war_config.nil? or war_config.size == 0
        raise 'NO war_config'
      end

      system "cd #{local_gitrepo}; git checkout #{branch}; git fetch; git merge origin/#{branch};"

      war_config.each do |config|
        puts "name=#{config[:name]}, war=#{config[:war]}"
        puts update_repository_local_command(config[:name], config[:war])
        system update_repository_local_command(config[:name], config[:war])
      end

      system "cd #{local_gitrepo}; git add .; git commit -m 'tag with #{tag_name}'; git tag #{tag_name};"

      # push tags and latest code
      system "cd #{local_gitrepo}; git push origin #{branch}"
      if $? != 0
        raise "git push failed"
      end

      system "cd #{local_gitrepo}; git push origin #{branch} --tags"
      if $? != 0
        raise "git push --tags failed"
      end
    end

    desc "deploy tagged version. use -s tag=xxx to set tag's name"
    task :deploy do
      tag_name = configuration[:tag]
      if tag_name.nil?
        rails "NO tag. pls use -s tag=xxx set tag_name"
      end

      run update_repository_remote_command(tag_name)
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
      [
       "cd #{local_gitrepo}",
       "if [ -e #{local_gitrepo}/#{name} ]",
       "then git rm -rf #{local_gitrepo}/#{name}",
       "fi",
       "mkdir -p #{local_gitrepo}/#{name}",
       "cd #{local_gitrepo}/#{name}",
       "jar -xf #{local_base_dir}/#{war}"
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
       "cd #{deploy_to_gitrepo}",
       "git fetch",
       "git checkout #{branch}",
       "git merge origin/#{branch}",
       "git checkout -b tag_#{tag_name} #{tag_name}",
      ].join("; ")
    end

  end

end
