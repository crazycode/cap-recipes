Dir[File.join(File.dirname(__FILE__), 'sdpdeploy/*.rb')].sort.each { |lib| require lib }
