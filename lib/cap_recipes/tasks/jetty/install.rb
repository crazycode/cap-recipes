require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  # JETTY SERVERS
  _cset :jetty_home, "/usr/local/jetty-7.1.6"
  _cset :jetty_ctrl, "/etc/init.d/jetty"

  #
  # simple interactions with the jetty server
  #
  namespace :jetty do

    desc "install jetty"
    task :install do
      dir = File.dirname(jetty_home)
      basename = File.basename(jetty_file)
      basectl = File.basename(jetty_ctrl)
      puts "#{jetty_file} ,,,, #{dir}  /#{basename}"
      utilities.sudo_upload "#{jetty_file}", "#{dir}/#{basename}"
      sudo "tar -zvxf #{dir}/#{basename} -C #{dir}"
      sudo "chown #{user}:root #{jetty_home} -R"

      put utilities.render("jetty", binding), "jetty.tmp"
      sudo "cp jetty.tmp #{jetty_ctrl}"
      sudo "chmod a+x #{jetty_ctrl}"
      sudo "/sbin/chkconfig --add #{basectl}"
      run "rm jetty.tmp"
      sudo "rm #{dir}/#{basename}"
    end

  end
end
