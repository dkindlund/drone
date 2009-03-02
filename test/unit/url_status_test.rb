require 'test_helper'

class UrlStatusTest < ActiveSupport::TestCase
  test "should not save url status without status and description" do
    c = UrlStatus.new
    assert !c.save, "Saved url status without status and description"
  end

  test "should not save duplicate url statuses" do
    a = UrlStatus.new(:status => "foo", :description => "bar")
    assert a.save

    b = UrlStatus.new(:status => "foo", :description => "bar")
    assert !b.save, "Saved duplicate url status"
  end
end
