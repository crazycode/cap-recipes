require File.expand_path(File.dirname(__FILE__) + '/../utilities')


Capistrano::Configuration.instance(true).load do
  namespace :mongodb do

    set :mongodb_path, "/data/db"
    desc "installs mongodb"
    task :install, :role => :app do
      utilities.apt_install "tcsh scons g++ libpcre++-dev libboost1.37-dev libreadline-dev xulrunner-dev"
    end
    after "mongodb:install", "mongodb:install_spidermonkey"


    task :install_spidermonkey, :role => :app do
      run "cd ~ ; mkdir -p tmp "
      run "cd ~/tmp ; wget ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz"
      run "cd ~/tmp ; tar -zxvf js-1.7.0.tar.gz"
      run "cd ~/tmp/js/src ; export CFLAGS=\"-DJS_C_STRINGS_ARE_UTF8\""
      run "cd ~/tmp/js/src ; #{sudo} make -f Makefile.ref"
      run "cd ~/tmp/js/src ; #{sudo} JS_DIST=/usr make -f Makefile.ref export"
    end
    after "mongodb:install_spidermonkey", "mongodb:install_mongodb"


    task :install_mongodb, :role => :app do
      sudo "rm -rf ~/tmp/mongo"
      run "cd ~/tmp ; git clone git://github.com/mongodb/mongo.git"
      run "cd ~/tmp/mongo ; #{sudo} scons all"
      run "cd ~/tmp/mongo ; #{sudo} scons --prefix=/opt/mongo install"
    end
    after "mongodb:install_mongodb", "mongodb:execute_db"


    task :execute_db, :role => :app do
      sudo "mkdir -p #{mongodb_path}"
      # sudo "/opt/mongo/bin/mongod --dbpath #{mongodb_path}"
    end

  end
end
