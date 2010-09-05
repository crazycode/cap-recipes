Dir[File.join(File.dirname(__FILE__), 'tomcat/*.rb')].sort.each { |lib| require lib }
