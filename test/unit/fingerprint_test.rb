require 'test_helper'

class FingerprintTest < ActiveSupport::TestCase
  test "should save fingerprint without checksum" do
    c = Fingerprint.new
    assert c.save, "Can't save fingerprint without checksum"
    assert_equal c.checksum, "d41d8cd98f00b204e9800998ecf8427e", "Checksum incorrect"
  end

  test "should save duplicate fingerprints" do
    a = Fingerprint.new(:checksum => "foo")
    assert a.save

    b = Fingerprint.new(:checksum => "foo")
    assert b.save, "Can't save duplicate fingerprint entry"
  end
end
