# ---- requirements
require 'rubygems'
require 'spec'

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
$LOAD_PATH << File.join(File.dirname(__FILE__),'..','..','bin')
# ---- bugfix
#`exit?': undefined method `run?' for Test::Unit:Module (NoMethodError)
#can be solved with require test/unit but this will result in extra test-output
module Test
  module Unit
    def self.run?
      true
    end
  end
end

Spec::Runner.configure do |config|
  config.mock_with :rr

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure 
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
end