require 'test_helper'

class ApplicationTest < ActiveSupport::TestCase
  test "should not save application without name and pid" do
    a = Application.new
    assert !a.save, "Saved application without name and pid"
  end

  test "should not save duplicate applications" do
    a = Application.new(:manufacturer => "foo", :version => "1.0", :short_name => "foo")
    assert a.save

    b = Application.new(:manufacturer => "foo", :version => "1.0", :short_name => "foo")
    assert !b.save, "Saved duplicate application entry"
  end
end
