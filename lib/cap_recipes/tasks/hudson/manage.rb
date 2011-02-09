require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  # HUDSON SERVERS
  _cset :hudson_home, "/opt/hudson"
  _cset :hudson_ctrl, "/etc/init.d/hudson"

  #
  # simple interactions with the hudson server
  #
  namespace :hudson do

    desc "install hudson"
    task :install do
      dir = File.dirname(hudson_home)
      basename = File.basename(hudson_file)
      basectl = File.basename(hudson_ctrl)
      puts "#{hudson_file} ,,,, #{dir}  /#{basename}"
      utilities.sudo_upload "#{hudson_file}", "#{dir}/#{basename}"
      sudo "tar -zvxf #{dir}/#{basename} -C #{dir}"
      sudo "chown #{user}:root #{hudson_home} -R"

      put utilities.render("hudson", binding), "hudson.tmp"
      sudo "cp hudson.tmp #{hudson_ctrl}"
      sudo "chmod a+x #{hudson_ctrl}"
      sudo "/sbin/chkconfig --add #{basectl}"
      run "rm hudson.tmp"
      sudo "rm #{dir}/#{basename}"
    end

  end
end
