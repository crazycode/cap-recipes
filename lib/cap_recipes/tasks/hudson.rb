Dir[File.join(File.dirname(__FILE__), 'hudson/*.rb')].sort.each { |lib| require lib }
