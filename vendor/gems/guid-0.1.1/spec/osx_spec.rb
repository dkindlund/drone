require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

describe Guid do
  it "does not load windows specific code on the Darwin platform" do
    script = <<-RUBY
      Object.send(:remove_const, :RUBY_PLATFORM)
      Object.const_set(:RUBY_PLATFORM, "darwin")
      require "guid"
    RUBY
    dir = File.dirname(__FILE__)
    system("cd #{dir}/../lib; ruby -e '#{script}'").should be_true
  end
end