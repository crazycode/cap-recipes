#Juggernaut install and management

Dir[File.join(File.dirname(__FILE__), 'juggernaut/*.rb')].sort.each { |lib| require lib }