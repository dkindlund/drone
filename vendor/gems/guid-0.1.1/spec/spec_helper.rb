require "rubygems"
require "spec"
require "rr"

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{dir}/../lib")
require "guid"

Spec::Runner.configure do |config|
  config.mock_with :rr
end
