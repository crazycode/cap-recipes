require 'cap_recipes/tasks/utilities.rb'

Capistrano::Configuration.instance(true).load do

set :install_path, "/usr/local/"

  namespace :ec2 do
    desc "install the ec2-amitools"
    task :install do
      run "unzip ec2-ami-tools.zip -d #{install_path}"
    end
    before "ec2:install", "ec2:install_dependencies"
    before "ec2:install", "ec2:download"
    
    desc "download the ec2-amitools"
    task :download do
      run "wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip" unless File.exists? "ec2-ami-tools.zip"
    end
    
    desc "install the ec2 dependencies"
    task :install_dependencies do
      utilities.apt_install %w[curl gzip openssl rsync]
    end
    
    desc "export ec2-ami-tools to EC2_AMITOOL_HOME and PATH"
    task :export do
      run "export EC2_AMITOOL_HOME=#{install_path}/ec2-ami-tools"
      run "export PATH=$PATH:${EC2_AMITOOL_HOME}/bin"
    end
    after "ec2:install", "ec2:export"
  end
end
