require 'test_helper'

class JobAlertTest < ActiveSupport::TestCase
  test "should not save job alert without protocol and address" do
    c = JobAlert.new
    assert !c.save, "Saved job alert without protocol and address"
  end

  test "should save duplicate job alerts" do
    a = JobAlert.new(:address  => "foo@foo.com",
                     :protocol => "smtp",
                     :job      => Job.find_by_uuid("3c70d4b6-a938-4de8-3f92-db7c7dc7fc9e"))
    assert a.save

    b = JobAlert.new(:address  => "foo@foo.com",
                     :protocol => "smtp",
                     :job      => Job.find_by_uuid("3c70d4b6-a938-4de8-3f92-db7c7dc7fc9e"))
    assert b.save, "Can't save duplicate job alert"
  end
end
