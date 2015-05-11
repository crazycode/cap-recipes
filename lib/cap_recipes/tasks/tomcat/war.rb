require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  # DEPLOYMENT SCHEME
  set :scm, :none
  set :deploy_via, :copy
  set :use_sudo, true

  _cset :deploy_to_parent, "/srv/applications"

  default_run_options[:pty] = true

  set :keep_releases, 5

  set :repository do
    fetch(:deploy_from)
  end

  set :deploy_from do
    dir = "/tmp/prep_#{release_name}"
    system("mkdir -p #{dir}")
    dir
  end

  # this is capistrano's default location.
  # depending on the permissions of the server
  # you may need to create it and chown it over
  # to :user (e.g. chown -R robotuser:robotuser /u)
  set :deploy_to do
    dir = "#{deploy_to_parent}/#{application}"
    sudo "mkdir -p #{dir}"
    sudo "chown #{user} #{dir}"
    dir
  end

  #
  # link the current/whatever.war into our webapps/whatever.war
  #
  #after 'deploy:setup' do
  #  cmd = "ln -s #{deploy_to}/current/`basename #{war}` #{tomcat_home}/webapps/`basename #{war}`"
  #  puts cmd
  #  sudo cmd
  #end

  # collect up our war into the deploy_from folder
  # notice that all we're doing is a copy here,
  # so it is pretty easy to swap this out for
  # a wget command, which makes sense if you're
  # using a continuous integration server like
  # bamboo. (more on this later).
  before 'deploy:update_code' do
    unless(war.nil?)
      puts "get war"
      system("mkdir #{deploy_from}/webapp")
      system("cp #{war} #{deploy_from}/webapp")
      system("cd #{deploy_from}/webapp && jar xf `basename #{war}`")
      system("rm -Rf #{deploy_from}/webapp/META-INF")
      system("rm #{deploy_from}/webapp/`basename #{war}`")
      puts system("ls -l #{deploy_from}")
    end
  end

  #
  # Disable all the default tasks that
  # either don't apply, or I haven't made work.
  #
  namespace :deploy do
    # restart tomcat
    task :restart do
      tomcat.restart
    end

    [ :upload, :cold, :start, :stop, :migrate, :migrations, :finalize_update ].each do |default_task|
      desc "[internal] disabled"
      task default_task do
        # disabled
      end
    end

    namespace :web do
      [ :disable, :enable ].each do |default_task|
        desc "[internal] disabled"
        task default_task do
          # disabled
        end
      end
    end

    namespace :pending do
      [ :default, :diff ].each do |default_task|
        desc "[internal] disabled"
        task default_task do
          # disabled
        end
      end
    end
  end
end
