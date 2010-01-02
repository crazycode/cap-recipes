%w[rubygems thor].each { |gem| require gem }
# require File.dirname(__FILE__) + "/../lib/templates"

class CapRecipes < Thor::Group
  include Thor::Actions

  def self.source_root; File.expand_path(File.dirname(__FILE__)); end
  def self.banner; "cap-recipes [path] task task2 task3"; end

  desc "Description: Generate deploy.rb file with desired tasks!"

  argument :path, :desc => "path to capify", :type => :string, :default => '.'
  argument :requires, :desc => "list of tasks to require", :type => :array, :default => []
  class_option :list, :desc => "list all recipes", :aliases => '-l', :type => :boolean, :default => false

  def capify
    unless options[:list]
      capfile_temp = "templates/Capfile.tt"
      deploy_temp = "templates/deploy.rb.tt"
      @recipes = requires.collect { |task| "require 'cap_recipes/tasks/#{task}'" }.join("\n")
      template capfile_temp, File.join(path,'/Capfile')
      template deploy_temp, File.join(path,'/config/deploy.rb')
    else
      folders = Dir.glob( File.dirname(__FILE__) + "/../lib/cap_recipes/tasks/*.rb").inject({}) do |packages,file|
        desc =  IO.readlines(file).first
        packages[File.basename(file, ".rb")] = ((desc =~ /#/) ? desc : "No description")
        packages
      end
      puts "Available Recipes:\n"
      puts folders.collect { |folder,desc| "\t* #{folder} - #{desc}"}.join("\n")
    end
  end

end