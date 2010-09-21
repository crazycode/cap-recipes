require 'fileutils'
require 'capistrano/recipes/deploy/scm'
require File.expand_path(File.dirname(__FILE__) + '/utilities')
require File.expand_path(File.dirname(__FILE__) + '/tomcat')

Capistrano::Configuration.instance(true).load do

  set :source_path, "source"

  set :scm, :subversion

  set :source_dir do
    "#{Dir.pwd}/#{source_path}"
  end

  namespace :mvn do

    desc "default mvn task. do svn update, package, and then deploy to tomcat"
    task :default do
      update_source
      build
    end

    desc "update code from scm from maven build."
    task :update_source do
      on_rollback { system "rm -rf #{source_dir}; true" }
      if Dir.exists?(source_dir)
        system source.sync(real_revision, source_dir)
      else
        system "mkdir #{source_dir}"
        system source.checkout(real_revision, source_dir)
      end
    end

    desc "build use maven2"
    task :build do
      system "cd #{source_dir}; mvn -Dmaven.test.skip=true clean install"
    end

    task :clean do
      if Dir.exists?("#{source_dir}/.svn")
        system "cd #{source_dir}; mvn clean"
      end
    end

    desc "deploy all module"
    task :mdeploy do
      if exists?(:modules)
        #default
        modules.each do |key, module_setting|
          set :scm, :none
          set :application, module_setting[:name]
          set :module_dir, module_setting[:module_dir].nil? ? name : module_setting[:module_dir]
          set :war, "#{source_dir}/#{module_dir}/target/#{module_setting[:war_name]}"
          set :webserver, module_setting[:webserver]

          set :scm, :none
          set :deploy_via, :copy
          set :use_sudo, true

          deploy.update_code :roles => webserver
        end
      end
    end
    desc "deploy all module"
    task :msetup do
      if exists?(:modules)
        #default
        modules.each do |key, module_setting|
          puts "do #{key}...#{module_setting[:name]}"
          set :scm, :none
          set :application, module_setting[:name]
          set :module_dir, module_setting[:module_dir].nil? ? name : module_setting[:module_dir]
          set :war, "#{source_dir}/#{module_dir}/target/#{module_setting[:war_name]}"
          set :webserver, module_setting[:webserver]

          set :scm, :none
          set :deploy_via, :copy
          set :use_sudo, true

          deploy.setup :roles => webserver
        end
      end
    end

  end

end
