require File.expand_path(File.dirname(__FILE__) + '/../utilities')


Capistrano::Configuration.instance(true).load do
  namespace :mongodb do

    set :mongo_db_path, "/data/db"
    desc "installs mongodb"
    task :install, :role => :app do
      utilities.apt_install "tcsh git-core scons g++ libpcre++-dev libboost1.37-dev libreadline-dev"
    end
      after "mongodb:install", "mongodb:install_spidermonkey"
      

    task :install_spidermonkey, :role => :app do
      run "cd ~ ; mkdir tmp "
      run "cd tmp ; wget ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz"
      run "cd tmp ; tar -zxvf js-1.7.0.tar.gz"
      run "cd js/src ; export CFLAGS=\"-DJS_C_STRINGS_ARE_UTF8\""
      run "cd js/src ; make -f Makefile.ref"
      sudo "cd js/src ;  JS_DIST=/usr make -f Makefile.ref export"
    end
      after "mongodb:install_spidermonkey", "mongodb:install_mongodb"
      

    task :install_mongodb, :role => :app do
      run "cd ~/tmp ; git clone git://github.com/mongodb/mongo.git"
      run "cd mongo ; scons all"
      sudo "cd mongo ;  scons --prefix=/opt/mongo install"
    end
    after "mongodb:install_mongodb", "mongodb:execute_db"
    

    task :execute_db, :role => :app do
      sudo "cd ~ ; mkdir -p #{mongo_db_path}"
      sudo "/opt/mongo/bin/mongod --dbpath #{mongo_db_path}"
    end

  end
end
