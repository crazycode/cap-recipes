Dir[File.join(File.dirname(__FILE__), 'gitdeploy/*.rb')].sort.each { |lib| require lib }
