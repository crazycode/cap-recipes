Capistrano::Configuration.instance(true).load do
  namespace :autointall do

    desc "GITgetgitDir_fromGitserver"
    task :autoInstallfileGetorUpdate, :max_hosts=>1 do
      run %{
              mkdir -p /opt/applications/;mkdir /opt/logs;
              mkdir -p /opt/autoinstalldir;cd /opt/autoinstalldir;pwd;
              git init;
              git remote add origin gituser@gitsource.shengpay.com:/opt/gitroot/autoinstalldir.git;
              git remote -v;
              git fetch;git fetch -t;git fetch;
              git pull origin master;
              ls -a;git status;
        }
    end


    task :install_Nginx,:mas_hosts=>1 do
      run %{
           cd  /opt/autoinstalldir;  sh nginx-install.sh;
       }
    end

    task :install_JDK,:mas_hosts=>1 do
      run %{
              cd /opt/autoinstalldir; sh java-install.sh;
       }
    end

    task :install_jboss,:mas_hosts=>1 do
      run %{
              cd /opt/autoinstalldir; sh  jboss-install.sh;
       }
    end

    task :install_memcached,:mas_hosts=>1 do
      run %{
              cd /opt/autoinstalldir; sh  memcached-install.sh;
       }
    end

    desc "for memcache "
    task :install_ttserver,:mas_hosts=>1 do
      run %{
              cd /opt/autoinstalldir; sh  tt-install.sh;
       }
    end

    desc "tomcat install task"
    task :tomcat_install, :max_hosts=>1 do
      run %{
                cd /opt/autoinstalldir; sh tomcat-install.sh ;
                echo "usage sh createInstance.sh -d tcServer1 -n 10000 -a 8010 -h 8080 -s 8440 -j 6900  to create tomcat instance";
              }
    end

    desc "tomcat instance create task"
    task :tomcat_instance_create, :max_hosts=>1 do
      run %{
               cd /opt/autoinstalldir/templateHome/bin ;
               pwd;
               ls -lhrt createInstance.sh;
               sh createInstance.sh -d #{instanceName} -n `expr 10000 + #{instanceNum}` -a `expr 8010 + #{instanceNum}` -h `expr 8080 + #{instanceNum}` -s `expr 8440 + #{instanceNum}` -j `expr 6900 + #{instanceNum}`;
               chown tomcat:tomcat /opt/tomcat -R; chmod +x  /opt/tomcat/*/bin/*
              }
    end

    desc " cmd from web"
    task :cmd_diy,:mas_hosts=>1 do
      run %{
           #{diy_cmd}
       }
    end

  end

end
