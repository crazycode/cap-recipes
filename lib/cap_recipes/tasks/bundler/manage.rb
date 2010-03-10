Capistrano::Configuration.instance(true).load do

  namespace :bundle do
    desc "Runs Gem Bundle after deployment"
    task :install do
      run "cd #{deploy_to}/current; bundle install"
    end

    desc "lock bundle"
    task :lock do
      run "cd #{deploy_to}/current; bundle lock"
    end

    desc "unlock bundle"
    task :unlock do
      run "cd #{deploy_to}/current; bundle unlock"
    end

    desc "show bundle"
    task :show do
      run "cd #{deploy_to}/current; bundle show"
    end
    
    desc "bundle check"
    task :show do
      run "cd #{deploy_to}/current; bundle check"
    end


  end
end
