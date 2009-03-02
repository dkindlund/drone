require 'test_helper'

class ClientStatusTest < ActiveSupport::TestCase
  test "should not save client status without status and description" do
    status = ClientStatus.new
    assert !status.save, "Saved client status without status and description"
  end

  test "should not save duplicate client status" do
    a = ClientStatus.new(:status      => "foo",
                         :description => "bar")
    assert a.save

    b = ClientStatus.new(:status      => "foo",
                         :description => "bar")
    assert !b.save, "Saved duplicate client status entry"
  end
end
