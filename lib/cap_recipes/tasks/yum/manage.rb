require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  namespace :yum do
    desc "Updates all installed packages on yum package system"
    task :updates do
      utilities.yum_update
    end

    desc "Installs a specified yum package"
    task :install do
      yum_pkg_name = utilities.ask "Enter name of the package(s) you wish to install:"
      raise "Please specify yum_pkg_name" if yum_pkg_name == ''
      logger.info "Updating packages..."
      sudo "yum update"
      logger.info "Installing #{yum_pkg_name}..."
      utilities.yum_install yum_pkg_name
    end

    desc "Removes a specified yum package"
    task :remove do
      yum_pkg_name = utilities.ask "Enter name of the package(s) you wish to remove:"
      raise "Please specify yum_pkg_name" if yum_pkg_name == ''
      logger.info "Updating packages..."
      sudo "yum update"
      logger.info "Removing #{yum_pkg_name}..."
      utilities.sudo_with_input "yum erase -y #{yum_pkg_name}", /^Do you want to continue\?/
    end
  end
end
