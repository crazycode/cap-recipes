Capistrano::Configuration.instance(true).load do
  namespace :atdp do

    begin
      puts "#{su_user}"
    rescue => error  then
      su_user_real="#{user}";puts "su user is user #{user}"
    else
      su_user_real="#{su_user}";puts "su user is su_user #{su_user}"
    end

    begin
      puts "#{servicename}"
    rescue => error  then
      scstop="echo there no win service;";
      scstart="echo there no win service;";
    else
      scstop="  sc stop  #{servicename} |grep STATE;  date;echo ping ;ping 127.0.0.1 -n 15 >> /dev/null ; date ;  sc query  #{servicename}  |grep STATE;  "
      scstart=" sc start  #{servicename} |grep STATE;  date;echo ping ;ping 127.0.0.1 -n 15 >> /dev/null ; date ;  sc query  #{servicename}  |grep STATE;"
    end

    begin
      puts "#{iispool}"
    rescue => error  then
      recyclepool="echo there no iis pool name;";
    else
      recyclepool="  cscript //Nologo \"C:\\windows\\system32\\iisapp.vbs\" /a #{iispool}  /r;  "
    end

    def getgitcmd(git_path,tag_name)
      gitstatDirls="ls -a;git status;echo ------------------------------;"
      git_cmd0="git reset --hard;git fetch;git fetch -t;git reset --merge #{tag_name};"
      git_cmd1="cd #{git_path}; #{gitstatDirls}  #{git_cmd0} #{gitstatDirls}  #{git_cmd0} #{gitstatDirls}"
      return git_cmd1
    end




    desc "default cmds : git-tag and restart "
    task :lux_git_restart, :max_hosts=>1 do
      _git_cmd=getgitcmd(git_path,tag_name)
      run %{
            #{_git_cmd}
            su - #{su_user_real}  -c  "#{appserver_cmd}  restart" ;
            su - #{su_user_real}  -c  "#{appserver_cmd}  status";
         }
    end

    desc "default cmds : stop git-tag start "
    task :luxstop_git_start, :max_hosts=>1 do
      _git_cmd=getgitcmd(git_path,tag_name)
      run %{
            su - #{su_user_real}  -c  "#{appserver_cmd}  stop" ;
            #{_git_cmd}
            su - #{su_user_real}  -c  "#{appserver_cmd}  start" ;
            su - #{su_user_real}  -c  "#{appserver_cmd}  status";
         }
    end

    desc "new git cmd include GBK SCREstart  no pre to prod "
    task :git_up_tag_new, :max_hosts=>1 do
      _git_cmd=getgitcmd(git_path,tag_name)
      if webistrano_project != "allpreverificationconfirm"  && tag_name =~ /pre_/i
      then capcmd="echo !!pre tag should not to production!!"
      else
        if webistrano_stage =~ /gbk/i then
          gitcmd="pwd;export LANG=zh_CN.GBK;#{_git_cmd}"
        else
          gitcmd= _git_cmd
        end
        if git_path =~ /website/i  then
          capcmd=" #{gitcmd}   #{recyclepool}"
        else
          capcmd="#{scstop}  #{gitcmd}  #{scstart}"
        end
      end
      run %{#{capcmd}}
    end




    desc "stop server or service"
    task :luxstop_serv, :max_hosts=>1 do
      run %{
            su - #{su_user_real}  -c  "#{appserver_cmd}  stop" ;
            su - #{su_user_real}  -c  "#{appserver_cmd}  status";
        }
    end

    desc "start server or service"
    task :luxstart_serv, :max_hosts=>1 do
      run %{
           su - #{su_user_real}  -c  "#{appserver_cmd}  start"   ;
           su - #{su_user_real}  -c  "#{appserver_cmd}  status";
        }
    end

    desc "restart server or service"
    task :luxrestart_serv, :max_hosts=>1 do
      run %{
            su - #{su_user_real}  -c  "#{appserver_cmd}  restart" ;
            su - #{su_user_real}  -c  "#{appserver_cmd}  status";
        }
    end

    desc "status server or service"
    task :luxstatus_serv, :max_hosts=>1 do
      run %{
            su - #{su_user_real}  -c  "#{appserver_cmd}  status;ps -efjH|grep java"
        }
    end

    desc "custom test cmd"
    task :custom_test, :max_hosts=>1 do
      run %{
            #{custom_test_cmd}
        }
    end




    desc "backup git path "
    task :backup_gitpath  do
      run %{
             tar -czf  #{git_path}.`date +%Y.%m.%d-%H.%M.%S`.tgz  #{git_path};
             ls  --full-time  -sh    #{git_path}.`date +%Y.%m.%d`*
        }
    end

    desc "recycleApplicationPool"
    task :iisrecycleApplicationPool   do
      run %{
            cscript //Nologo "C:\\windows\\system32\\iisapp.vbs" /a #{iispool} /r
        }
    end

    desc "startApplicationPool"
    task :iisstartApplicationPool, :max_hosts=>1 do
      run %{
            cscript  "C:\\Inetpub\\AdminScripts\\adsutil.vbs"  START_SERVER  W3SVC/AppPools/#{iispool}
        }
    end




    desc "service start"
    task :winstartservice, :max_hosts=>1 do
      run %{
            #{scstart}
         }
    end

    desc "service stop"
    task :winstopservice, :max_hosts=>1 do
      run %{
            #{scstop}
        }
    end

    desc "service restart"
    task :winServiceRestart, :max_hosts=>1 do
      run %{
    #{scstop}
    #{scstart}       }
    end




    desc "push product to git server !!!!!no git log"
    task :GITdailypushprod_togitserv, :max_hosts=>1 do
      run %{
              cd #{git_path};
              pwd;ls -a;git status;
              git add . ;
              git commit -am "product webistrano auto `date +%Y.%m.%d-%H.%M.%S`  `pwd` " ;
              git push origin master ;
              ls -a;git status;
        }
    end

    desc "push product to git server"
    task :GITinitpushprod_togitserv, :max_hosts=>1 do
      run %{
              cd #{git_path};
              pwd;ls -a;
              git init;
              git add . ;
              git commit -am "product webistrano auto `date +%Y.%m.%d-%H.%M.%S`   `pwd` " ;
              git remote add origin gituser@gitsource.shengpay.com:#{git_repopath}  ;
              git remote -v;
              git push origin master ;
              ls -a;git status
        }
    end

    desc "init stage git in dp server"
    task :GITonlyInitgit_indpserv, :max_hosts=>1 do
      run %{
              cd #{git_path};
              pwd;ls -a;
              git init;
              git remote add origin gituser@gitsource.shengpay.com:#{git_repopath}  ;
              git remote -v;
              ls -a;git status
        }
    end

    desc "GITgetgitDir_fromGitserver"
    task :GITinitgetgitDirfromGitserver, :max_hosts=>1 do
      run %{
              dir=`date +%Y%m%d%H%M%S`;  cd /tmp;pwd;git clone gituser@gitsource.shengpay.com:#{git_repopath}  $dir;
              cd #{git_path};pwd;ls -a; cp -r /tmp/$dir/.git    ./; ls -a;git status;
        }
    end



    desc "push product to git server"
    task :Git_Ip_initpushprod_togitserv, :max_hosts=>1 do
      run %{
              cd #{git_path};
              pwd;ls -a;
              git init;
              git add . ;
              git commit -am "product webistrano auto `date +%Y.%m.%d-%H.%M.%S`   `pwd` " ;
              git remote add origin gituser@114.80.132.203:#{git_repopath}  ;
              git remote -v;
              git push origin master ;
              ls -a;git status
        }
    end

    desc "init stage git in dp server"
    task :Git_Ip_onlyInitgit_indpserv, :max_hosts=>1 do
      run %{
              cd #{git_path};
              pwd;ls -a;
              git init;
              git remote add origin gituser@114.80.132.203:#{git_repopath}  ;
              git remote -v;
              ls -a;git status
        }
    end

    desc "GITgetgitDir_fromGitserver"
    task :Git_Ip_InitGetGitDir_fromGitserver, :max_hosts=>1 do
      run %{
              dir=`date +%Y%m%d%H%M%S`;  cd /tmp;pwd;git clone gituser@114.80.132.203:#{git_repopath}  $dir;
              cd #{git_path};pwd;ls -a; cp -r /tmp/$dir/.git    ./; ls -a;git status;
        }
    end




    desc "get iis info"
    task :iisinfo, :max_hosts=>1 do
      run %{
                       cscript.exe "c:\\Inetpub\\AdminScripts\\adsutil.vbs"   ENUM /P W3SVC/AppPools;
                       cscript //Nologo "C:\\windows\\system32\\iisweb.vbs" /query |awk -F")" '{print $1}'|awk -F"(" '{print $2}'|grep W3SVC|grep -vE "W3SVC/1$" |xargs  -I {} cscript.exe "c:\\Inetpub\\AdminScripts\\adsutil.vbs"  ENUM_ALL {}|grep -E "AppPoolId|Path|Comment"
         }
    end

  end

end

