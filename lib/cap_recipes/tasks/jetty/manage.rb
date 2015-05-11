Capistrano::Configuration.instance(true).load do
  #
  # simple interactions with the jetty server
  #
  namespace :jetty do

    desc "start jetty"
    task :start do
      sudo "#{jetty_ctrl} start"
    end

    desc "stop jetty"
    task :stop do
      sudo "#{jetty_ctrl} stop"
    end

    desc "stop and start jetty"
    task :restart do
      jetty.stop
      jetty.start
    end

    desc "list jetty process"
    task :ps do
      run "ps aux | grep jetty | grep -v grep"
    end

    desc "tail :jetty_home/logs/*.log and logs/catalina.out"
    task :tail do
      stream "tail -f #{jetty_home}/logs/*.log"
    end

  end
end
