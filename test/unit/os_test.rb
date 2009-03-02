require 'test_helper'

class OsTest < ActiveSupport::TestCase
  test "should not save os without name, version, and short name" do
    c = Os.new
    assert !c.save, "Saved os without name, version, and short name"
  end

  test "should not save duplicate os" do
    a = Os.new(:name       => "Windows XP",
               :version    => "1.0",
               :short_name => "Microsoft Windows")
    assert a.save

    b = Os.new(:name       => "Windows XP",
               :version    => "1.0",
               :short_name => "Microsoft Windows")
    assert !b.save, "Saved duplicate os entry"
  end
end
