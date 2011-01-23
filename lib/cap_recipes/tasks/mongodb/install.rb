require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/manage')

Capistrano::Configuration.instance(true).load do
  default_run_options[:pty] = true

  #set :mongodb_data_path, "/data/db"
  set :mongodb_bin_path, "/opt/mongo"

  _cset :mongodb_nodename, "node0"
  _cset :mongodb_name, "mongod_#{mongodb_nodename}"
  _cset :mongod_conf, "/etc/#{mongodb_name}.conf"
  _cset :mongodb_init, "/etc/init.d/#{mongodb_name}"
  _cset :mongodb_data_path, "/var/data/#{mongodb_name}"
  _cset :mongodb_port, 27017

  namespace :mongodb do
    desc "Installs mongodb binaries and all dependencies"
    task :install, :role => :app do
      utilities.apt_install "tcsh scons g++ libpcre++-dev"
      utilities.apt_install "libboost1.37-dev libreadline-dev xulrunner-dev"
      mongodb.make_spidermonkey
      mongodb.make_mongodb
      mongodb.setup_db_path
    end

    task :make_spidermonkey, :role => :app do
      run "mkdir -p ~/tmp"
      run "cd ~/tmp; wget ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz"
      run "cd ~/tmp; tar -zxvf js-1.7.0.tar.gz"
      run "cd ~/tmp/js/src; export CFLAGS=\"-DJS_C_STRINGS_ARE_UTF8\""
      run "cd ~/tmp/js/src; #{sudo} make -f Makefile.ref"
      run "cd ~/tmp/js/src; #{sudo} JS_DIST=/usr make -f Makefile.ref export"
    end

    task :make_mongodb, :role => :app do
      sudo "rm -rf ~/tmp/mongo"
      run "cd ~/tmp; git clone git://github.com/mongodb/mongo.git"
      run "cd ~/tmp/mongo; #{sudo} scons all"
      run "cd ~/tmp/mongo; #{sudo} scons --prefix=#{mongodb_bin_path} install"
    end

    task :setup_db_path, :role => :app do
      sudo "mkdir -p #{mongodb_data_path}"
      mongodb.start
    end

    task :setup_node, :role => :app do

      # create config file
      put utilities.render("mongod.conf", binding), "mongod.conf.tmp"
      put utilities.render("mongodb.init", binding), "mongodb.init.tmp"
      sudo "cp mongod.conf.tmp #{mongod_conf}"
      sudo "cp mongodb.init.tmp #{mongodb_init}"
      #sudo "/sbin/chkconfig --add #{mongodb_name}"
      run "rm mongod.conf.tmp"
      run "rm mongodb.init.tmp"

      sudo "mkdir -p #{mongodb_data_path}"
      sudo "chown mongod:mongod #{mongodb_data_path}"

    end
  end
end
