require 'test_helper'

class FileContentTest < ActiveSupport::TestCase
  test "should not save file content without md5, sha1, size, and mime type" do
    c = FileContent.new
    assert !c.save, "Saved file content without md5, sha1, size, and mime type"
  end

  test "should not save duplicate file contents" do
    a = FileContent.new(:md5       => "foo",
                        :sha1      => "bar",
                        :size      => 123,
                        :mime_type => "application/x-ms-dos-executable")
    assert a.save

    b = FileContent.new(:md5       => "foo",
                        :sha1      => "bar",
                        :size      => 123,
                        :mime_type => "application/x-ms-dos-executable")
    assert !b.save, "Saved duplicate file content entry"
  end

  test "should save nested file contents" do
    time = Time.now
    a = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar",
                                                         :pid  => 123,
                                                         :process_files => [ ProcessFile.new(:name => "baz",
                                                                                             :event => "Write",
                                                                                             :time_at => time.to_f,
                                                                                             :file_content => FileContent.new(
                                                                                                               :md5  => "foo1",
                                                                                                               :sha1 => "bar1",
                                                                                                               :size => 123,
                                                                                                               :mime_type => "application/x-ms-dos-executable")
                                                                             ) ]
                                           ) ] )
    assert a.save
  end
end
