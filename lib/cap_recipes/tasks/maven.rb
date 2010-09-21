require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/utilities')
require File.expand_path(File.dirname(__FILE__) + '/tomcat')

Capistrano::Configuration.instance(true).load do

  set :source_path, "source"

  set :source_dir do

  end

  namespace :mvn do

    desc "default mvn task. do svn update, package, and then deploy to tomcat"
    task :default do
      puts Dir.pwd
    end

    task :update_source do
      run "svn "
    end

  end
  namespace :deploy do
    set :modules, {
      :admin_module => {
        :name => "message-admin",
        :module_locate => "message-admin",
        :war_name => "message-admin.war",
        :webserver => "10.241.12.44"
      },
      :web_module => {
        :name => "message-web",
        :module_locate => "message-admin",
        :war_name => "message-admin.war",
        :webserver => "10.241.12.44"
      }
    }

    task :default do
      if exists?(:modules)
        modules.each do |key, module_setting|
          set :name, module_setting[:name]
          set :war, File.dirname(__FILE__) + "/svn/message/message-web/target/message-web.war"
          set :war,
        end
      end
    end

  end
end
