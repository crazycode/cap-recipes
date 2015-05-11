Capistrano::Configuration.instance(true).load do
  #
  # simple interactions with the tomcat server
  #
  namespace :tomcat do

    desc "start tomcat"
    task :start do
      sudo "#{tomcat_ctrl} start"
    end

    desc "stop tomcat"
    task :stop do
      sudo "#{tomcat_ctrl} stop"
    end

    desc "stop and start tomcat"
    task :restart do
      tomcat.stop
      tomcat.start
    end

    desc "list tomcat process"
    task :ps do
      run "ps aux | grep tomcat | grep -v grep"
    end

    desc "tail :tomcat_home/logs/*.log and logs/catalina.out"
    task :tail do
      stream "tail -f #{tomcat_home}/logs/*.log #{tomcat_home}/logs/catalina.out"
    end

  end
end
