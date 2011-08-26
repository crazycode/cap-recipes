Dir[File.join(File.dirname(__FILE__), 'sft/*.rb')].sort.each { |lib| require lib }
