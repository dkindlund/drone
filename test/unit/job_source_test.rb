require 'test_helper'

class JobSourceTest < ActiveSupport::TestCase
  test "should not save job source without name and protocol" do
    c = JobSource.new
    assert !c.save, "Saved job without name and protocol"
  end

  test "should not save duplicate job sources" do
    a = JobSource.new(:name => "foo", :protocol => "bar")
    assert a.save

    b = JobSource.new(:name => "foo", :protocol => "bar")
    assert !b.save, "Saved duplicate job source entry"
  end
end
