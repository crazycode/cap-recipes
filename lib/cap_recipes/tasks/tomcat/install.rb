require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  default_run_options[:pty] = true
  set :use_sudo, true

  # TOMCAT SERVERS
  _cset :tomcat_home, "/usr/local/apache-tomcat-6.0.29"
  _cset :tomcat_ctrl, "/etc/init.d/tomcat"
  _cset :java_home, "/usr/lib/jvm/java"

  #
  # simple interactions with the tomcat server
  #
  namespace :tomcat do

    set :tomcat_user, do
      user   # default use current user.
    end

    desc "install tomcat"
    task :install, :role => :app do
      dir = File.dirname(tomcat_home)
      basename = File.basename(tomcat_file)
      basectl = File.basename(tomcat_ctrl)
      puts "#{tomcat_file} ,,,, #{dir}  /#{basename}"
      #utilities.sudo_upload "#{tomcat_file}", "#{dir}/#{basename}"
      #sudo "mkdir -p #{dir}"
      #sudo "tar -zvxf #{dir}/#{basename} -C #{dir}"
      #sudo "chown #{user}:root #{tomcat_home} -R"

      put utilities.render("tomcat", binding), "/tmp/tomcat.tmp"
      sudo "cp /tmp/tomcat.tmp #{tomcat_ctrl}"
      sudo "chmod a+x #{tomcat_ctrl}"
      sudo "/sbin/chkconfig --add #{basectl}"
      run "rm /tmp/tomcat.tmp"
      sudo "rm #{dir}/#{basename}"
    end

  end
end
