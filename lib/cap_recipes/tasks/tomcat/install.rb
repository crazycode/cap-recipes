require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  set :scm, :none
  set :deploy_via, :copy

  #
  # simple interactions with the tomcat server
  #
  namespace :tomcat do

    desc "install tomcat"
    task :install do
      dir = File.dirname(tomcat_home)
      basename = File.basename(tomcat_file)
      basectl = File.basename(tomcat_ctrl)
      puts "#{tomcat_file} ,,,, #{dir}  /#{basename}"
      utilities.sudo_upload "#{tomcat_file}", "#{dir}/#{basename}"
      sudo "tar -zvxf #{dir}/#{basename} -C #{dir}"
      sudo "chown #{user}:root #{tomcat_home} -R"

      put utilities.render("tomcat", binding), "tomcat.tmp"
      sudo "cp tomcat.tmp #{tomcat_ctrl}"
      sudo "chmod a+x #{tomcat_ctrl}"
      sudo "/sbin/chkconfig --add #{basectl}"
      run "rm tomcat.tmp"
      sudo "rm #{dir}/#{basename}"
    end

  end
end
