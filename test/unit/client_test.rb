require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test "should not save clients without quick_clone_name and snapshot_name" do
    c = Client.new
    assert !c.save, "Saved client without quick_clone_name and snapshot_name"
  end

  test "should not save clients without host and status" do
    c = Client.new(:quick_clone_name => "foo", :snapshot_name => "bar")
    assert !c.save, "Saved client without host and status"
  end

  test "should not save duplicate clients" do
    a = Client.new(:quick_clone_name => "foo",
                   :snapshot_name    => "bar",
                   :client_status    => ClientStatus.find_by_status("created"),
                   :host             => Host.find_by_hostname("honeyclient1.foo.com"))
    assert a.save

    b = Client.new(:quick_clone_name => "foo",
                   :snapshot_name    => "bar",
                   :client_status    => ClientStatus.find_by_status("created"),
                   :host             => Host.find_by_hostname("honeyclient1.foo.com"))
    assert !b.save, "Saved duplicate client entry"
  end
end
