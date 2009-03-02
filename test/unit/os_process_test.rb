require 'test_helper'

class OsProcessTest < ActiveSupport::TestCase
  test "should not save os process without name and pid" do
    c = OsProcess.new
    assert !c.save, "Saved os process without name and pid"
  end

  test "should save duplicate os processes" do
    a = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar", :pid => 123) ] )
    assert a.save
    a.reload
    assert_equal a.os_process_count, 1, "Os process count not accurate"

    b = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar", :pid => 123) ] )
    assert b.save, "Can't save duplicate os process entry"
    b.reload
    assert_equal b.os_process_count, 1, "Os process count not accurate"
  end
end
