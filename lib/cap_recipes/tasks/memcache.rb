# Manages memcache

Dir[File.join(File.dirname(__FILE__), 'memcache/*.rb')].sort.each { |lib| require lib }