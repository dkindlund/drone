require 'test_helper'

class ProcessFileTest < ActiveSupport::TestCase
  test "should not save process file without name, event, and time_at" do
    c = ProcessFile.new
    assert !c.save, "Saved process file without name, event, and time_at"
  end

  test "should save duplicate process files" do
    time = Time.now
    a = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar",
                                                         :pid  => 123,
                                                         :process_files => [ ProcessFile.new(:name => "baz",
                                                                                             :event => "Write",
                                                                                             :time_at => time.to_f
                                                                             ) ]
                                           ) ] )
    assert a.save
    a.reload
    assert_equal a.os_processes.first.process_file_count, 1, "Process file count not accurate"

    b = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar",
                                                         :pid  => 123,
                                                         :process_files => [ ProcessFile.new(:name => "baz",
                                                                                             :event => "Write",
                                                                                             :time_at => time.to_f
                                                                             ) ]
                                           ) ] )
    assert b.save, "Can't save duplicate process file entry"
    b.reload
    assert_equal b.os_processes.first.process_file_count, 1, "Process file count not accurate"
  end
end
