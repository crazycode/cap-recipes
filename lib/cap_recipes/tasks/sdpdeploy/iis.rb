Capistrano::Configuration.instance(true).load do
namespace :atiiscmd do
    
    desc "recycleApplicationPool"
    task :recycleApplicationPool, :max_hosts=>1 do
        run %{
            cscript //Nologo "C:\\windows\\system32\\iisapp.vbs" /a #{iispool} /r
        }
    end

    desc "iis website status"
    task :iis_site_status, :max_hosts=>1 do
        run %{
            cscript //Nologo "C:\\windows\\system32\\iisweb.vbs" /query #{iiswebsite} 
        }
    end

    desc "iis website status all"
    task :iis_site_status_all, :max_hosts=>1 do
        run %{
            cscript //Nologo "C:\\windows\\system32\\iisweb.vbs" /query 
        }
    end

    desc "iis website start"
    task :iis_site_start, :max_hosts=>1 do
        run %{
            cscript //Nologo "C:\\windows\\system32\\iisweb.vbs" /start #{iiswebsite} 
        }
    end

    desc "iis website stop"
    task :iis_site_stop, :max_hosts=>1 do
        run %{
            cscript //Nologo "C:\\windows\\system32\\iisweb.vbs" /stop #{iiswebsite} 
        }
    end

    desc "iis iisreset stop"
    task :iis_stop, :max_hosts=>1 do
        run %{
            iisreset /stop
        }
    end

    desc "iis iisreset start"
    task :iis_start, :max_hosts=>1 do
        run %{
            iisreset /start
        }
    end

    desc "iis iisreset status"
    task :iis_status, :max_hosts=>1 do
        run %{
            iisreset /status
        }
    end

    desc "iis iisreset restart"
    task :iis_restart, :max_hosts=>1 do
        run %{
            iisreset /restart
        }
    end

    desc "iis website deploy dir"
    task :iis_dp_dir_info, :max_hosts=>1 do
        run " grep -nE 'ServerComment|Path' /cygdrive/c/WINDOWS/system32/inetsrv/MetaBase.xml  |grep -vE 'tPath|rPath|默认|允许' "
    end
end
end
