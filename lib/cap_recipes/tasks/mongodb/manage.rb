require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  
  namespace :mongodb do
    
    set :mongodb_log, "/var/log/mongodb.log"
    
    desc "start mongodb server"
    task :start, :role => :app do
      sudo "/opt/mongo/bin/mongod --fork --logpath #{mongodb_log} --logappend --dbpath #{mongodb_path}"
    end

    desc "stop mongodb server"
    task :stop, :role => :app do
      pid = capture("ps -o pid,command ax | grep mongod | awk '!/awk/ && !/grep/ {print $1}'")
      run "kill -2 #{pid}" if pid
    end

    desc "restart mongodb server"
    task :restart, :role => :app do
      mongodb.stop
      mongodb.start
    end

  end
end
