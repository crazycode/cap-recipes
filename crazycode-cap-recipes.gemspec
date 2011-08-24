# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{crazycode-cap-recipes}
  s.version = "0.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["crazycode"]
  s.date = %q{2011-08-24}
  s.default_executable = %q{cap-recipes}
  s.description = %q{Battle-tested capistrano recipes for debian, passenger, apache, hudson, delayed_job, juggernaut, rubygems, backgroundrb, rails and more}
  s.email = %q{crazycode@gmail.com}
  s.executables = ["cap-recipes"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    "Capfile",
    "LICENSE",
    "README.textile",
    "Rakefile",
    "VERSION.yml",
    "bin/cap-recipes",
    "cap-recipes.gemspec",
    "config/deploy.rb",
    "crazycode-cap-recipes.gemspec",
    "examples/advanced/deploy.rb",
    "examples/advanced/deploy/experimental.rb",
    "examples/advanced/deploy/production.rb",
    "examples/simple/deploy.rb",
    "lib/cap_recipes.rb",
    "lib/cap_recipes/tasks/apache.rb",
    "lib/cap_recipes/tasks/apache/install.rb",
    "lib/cap_recipes/tasks/apache/manage.rb",
    "lib/cap_recipes/tasks/aptitude.rb",
    "lib/cap_recipes/tasks/aptitude/manage.rb",
    "lib/cap_recipes/tasks/backgroundrb.rb",
    "lib/cap_recipes/tasks/backgroundrb/hooks.rb",
    "lib/cap_recipes/tasks/backgroundrb/manage.rb",
    "lib/cap_recipes/tasks/bundler.rb",
    "lib/cap_recipes/tasks/bundler/manage.rb",
    "lib/cap_recipes/tasks/cmdb.rb",
    "lib/cap_recipes/tasks/cmdbutils.rb",
    "lib/cap_recipes/tasks/delayed_job.rb",
    "lib/cap_recipes/tasks/delayed_job/hooks.rb",
    "lib/cap_recipes/tasks/delayed_job/manage.rb",
    "lib/cap_recipes/tasks/ec2/install.rb",
    "lib/cap_recipes/tasks/ec2/manage.rb",
    "lib/cap_recipes/tasks/gitdeploy.rb",
    "lib/cap_recipes/tasks/gitdeploy/setup.rb",
    "lib/cap_recipes/tasks/gitosis.rb",
    "lib/cap_recipes/tasks/gitosis/install.rb",
    "lib/cap_recipes/tasks/gitosis/manage.rb",
    "lib/cap_recipes/tasks/http.rb",
    "lib/cap_recipes/tasks/hudson.rb",
    "lib/cap_recipes/tasks/hudson/manage.rb",
    "lib/cap_recipes/tasks/jetty.rb",
    "lib/cap_recipes/tasks/jetty/install.rb",
    "lib/cap_recipes/tasks/jetty/manage.rb",
    "lib/cap_recipes/tasks/jetty/web.rb",
    "lib/cap_recipes/tasks/juggernaut.rb",
    "lib/cap_recipes/tasks/juggernaut/hooks.rb",
    "lib/cap_recipes/tasks/juggernaut/manage.rb",
    "lib/cap_recipes/tasks/maven.rb",
    "lib/cap_recipes/tasks/memcache.rb",
    "lib/cap_recipes/tasks/memcache/hooks.rb",
    "lib/cap_recipes/tasks/memcache/install.rb",
    "lib/cap_recipes/tasks/memcache/manage.rb",
    "lib/cap_recipes/tasks/mongodb.rb",
    "lib/cap_recipes/tasks/mongodb/install.rb",
    "lib/cap_recipes/tasks/mongodb/manage.rb",
    "lib/cap_recipes/tasks/passenger.rb",
    "lib/cap_recipes/tasks/passenger/install.rb",
    "lib/cap_recipes/tasks/passenger/manage.rb",
    "lib/cap_recipes/tasks/rails.rb",
    "lib/cap_recipes/tasks/rails/hooks.rb",
    "lib/cap_recipes/tasks/rails/manage.rb",
    "lib/cap_recipes/tasks/ruby.rb",
    "lib/cap_recipes/tasks/ruby/install.rb",
    "lib/cap_recipes/tasks/rubygems.rb",
    "lib/cap_recipes/tasks/rubygems/install.rb",
    "lib/cap_recipes/tasks/rubygems/manage.rb",
    "lib/cap_recipes/tasks/sdpjenkins.rb",
    "lib/cap_recipes/tasks/templates/hudson.erb",
    "lib/cap_recipes/tasks/templates/mongod.conf.erb",
    "lib/cap_recipes/tasks/templates/mongodb.init.erb",
    "lib/cap_recipes/tasks/templates/mongodb.repo.erb",
    "lib/cap_recipes/tasks/templates/mongos.init.erb",
    "lib/cap_recipes/tasks/templates/tomcat.erb",
    "lib/cap_recipes/tasks/thinking_sphinx.rb",
    "lib/cap_recipes/tasks/thinking_sphinx/hooks.rb",
    "lib/cap_recipes/tasks/thinking_sphinx/install.rb",
    "lib/cap_recipes/tasks/thinking_sphinx/manage.rb",
    "lib/cap_recipes/tasks/tomcat.rb",
    "lib/cap_recipes/tasks/tomcat/install.rb",
    "lib/cap_recipes/tasks/tomcat/manage.rb",
    "lib/cap_recipes/tasks/tomcat/war.rb",
    "lib/cap_recipes/tasks/utilities.rb",
    "lib/cap_recipes/tasks/whenever.rb",
    "lib/cap_recipes/tasks/whenever/hooks.rb",
    "lib/cap_recipes/tasks/whenever/manage.rb",
    "lib/cap_recipes/tasks/yum.rb",
    "lib/cap_recipes/tasks/yum/manage.rb",
    "lib/capify.rb",
    "lib/templates/Capfile.tt",
    "lib/templates/deploy.rb.tt",
    "spec/cap/all/Capfile",
    "spec/cap/helper.rb",
    "spec/cap_recipes_spec.rb",
    "spec/spec_helper.rb",
    "specs.watchr",
    "test.rb"
  ]
  s.homepage = %q{http://github.com/crazycode/cap-recipes}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{crazycode-cap-recipes}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Battle-tested capistrano recipes for passenger, delayed_job, and more}
  s.test_files = [
    "examples/advanced/deploy.rb",
    "examples/advanced/deploy/experimental.rb",
    "examples/advanced/deploy/production.rb",
    "examples/simple/deploy.rb",
    "spec/cap/helper.rb",
    "spec/cap_recipes_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<addressable>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<addressable>, [">= 0"])
  end
end

