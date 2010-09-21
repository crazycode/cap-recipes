Capistrano::Configuration.instance(true).load do

  set :source_path, "source"

  namespace :mvn do

    desc "default mvn task. do svn update, package, and then deploy to tomcat"
    task :default do
    end

    task :update_source do
      run "svn "
    end

  end
end
