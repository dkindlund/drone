require 'test_helper'

class HostTest < ActiveSupport::TestCase
  test "should not save host without hostname and ip" do
    c = Host.new
    assert !c.save, "Saved host without hostname and ip"
  end

  test "should not save duplicate hosts" do
    a = Host.new(:hostname => "honeyclient9.foo.com",
                 :ip       => "10.0.0.9")
    assert a.save

    b = Host.new(:hostname => "honeyclient9.foo.com",
                 :ip       => "10.0.0.9")
    assert !b.save, "Saved duplicate host entry"
  end
end
