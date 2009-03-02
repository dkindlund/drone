require 'test_helper'

class FingerprintTest < ActiveSupport::TestCase
  test "should not save fingerprint without checksum" do
    c = Fingerprint.new
    assert !c.save, "Saved fingerprint without checksum"
  end

  test "should save duplicate fingerprints" do
    a = Fingerprint.new(:checksum => "foo")
    assert a.save

    b = Fingerprint.new(:checksum => "foo")
    assert b.save, "Can't save duplicate fingerprint entry"
  end
end
