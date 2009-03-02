require 'test_helper'

class UrlStatisticTest < ActiveSupport::TestCase
  test "should not save url statistic without count and url status" do
    c = UrlStatistic.new
    assert !c.save, "Saved url statistic without count and url status"
  end

  test "should not save duplicate url statistics" do
    time = Time.now
    UrlStatistic.record_timestamps = false
    a = UrlStatistic.new(:count => 5,
                         :url_status => UrlStatus.find_by_status("visited"),
                         :created_at => (time - 1.hour).to_s,
                         :updated_at => time.to_s)
    assert a.save

    b = UrlStatistic.new(:count => 5,
                         :url_status => UrlStatus.find_by_status("visited"),
                         :created_at => (time - 1.hour).to_s,
                         :updated_at => time.to_s)
    assert !b.save, "Saved duplicate url statistic"
    UrlStatistic.record_timestamps = true
  end
end
