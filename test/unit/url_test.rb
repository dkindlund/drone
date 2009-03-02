require 'test_helper'
require 'guid'

class UrlTest < ActiveSupport::TestCase
  test "should not save url without url, priority, and url status" do
    c = Url.new
    assert !c.save, "Saved url without url, priority, and url status"
  end

  test "should save duplicate urls" do
    a = Job.new(:uuid => Guid.new.to_s,
                :job_source => JobSource.find_by_name_and_protocol("Unique Source 1", "http"),
                :urls => [ Url.new(:url => "http://www.google.com/", 
                                   :priority => 10,
                                   :url_status => UrlStatus.find_by_status("queued")) ])
    assert a.save

    b = Job.new(:uuid => Guid.new.to_s,
                :job_source => JobSource.find_by_name_and_protocol("Unique Source 1", "http"),
                :urls => [ Url.new(:url => "http://www.google.com/", 
                                   :priority => 10,
                                   :url_status => UrlStatus.find_by_status("queued")) ])
    assert b.save, "Can't save duplicate url entry"
  end
end
