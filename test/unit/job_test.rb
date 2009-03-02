require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "should not save job without uuid" do
    c = Job.new
    assert !c.save, "Saved job without uuid"
  end

  test "should not save duplicate jobs" do
    a = Job.new(:uuid => "foo", :job_source => JobSource.find_by_name_and_protocol("Unique Source 1", "http"))
    assert a.save

    b = Job.new(:uuid => "foo", :job_source => JobSource.find_by_name_and_protocol("Unique Source 1", "http"))
    assert !b.save, "Saved duplicate job entry"
  end
end
