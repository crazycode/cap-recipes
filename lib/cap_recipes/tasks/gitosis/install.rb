Capistrano::Configuration.instance(true).load do

	namespace :gitosis do

		desc "install Gitosis"
		task :install do
			gitosis.install_packages
			gitosis.setup_packages
			gitosis.setup_git_user
			gitosis.set_permissions
			gitosis.copy_ssh
		end
		
		desc "update the system"
		task :update_system do
			%[update dist-upgrade].each { |cmd| sudo "apt-get #{cmd}"}
		end
	
		desc "install all necessary packages"
		task :install_packages do
			gitosis.update_system
			%[git-core python-setuptools].each { |package| sudo "apt-get install #{package}" }
		end

		desc "setup packages"
		task :setup_packages do
			run "mkdir ~/src && cd ~/src"
			run "git clone git://eagain.net/gitosis.git"
			run "cd ~/src/gitosis"
			sudo "python setup.py install"
		end

		desc "setup git user"
		task :setup_git_user do
			sudo "adduser --system --shell /bin/sh --gecos \'git version control\' --group --disabled-password --home /home/git git"
		end
	
		desc "copy over servers own ssh, important for self pull"
		task :copy_ssh do
			run "sudo -H -u git gitosis-init < /home/#{user}/.ssh/id_rsa.pub"
		end
	
		desc "set permissions"
		task :set_permissions do
			sudo "chmod 755 /home/git/repositories/gitosis-admin.git/hooks/post-update"
		end
	
	end
end
