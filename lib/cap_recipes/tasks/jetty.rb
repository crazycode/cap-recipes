Dir[File.join(File.dirname(__FILE__), 'jetty/*.rb')].sort.each { |lib| require lib }
