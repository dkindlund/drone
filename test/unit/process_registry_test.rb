require 'test_helper'

class ProcessRegistryTest < ActiveSupport::TestCase
  test "should not save process registry without name, event, and time_at" do
    c = ProcessRegistry.new
    assert !c.save, "Saved process registry without name, event, and time_at"
  end

  test "should save duplicate process registries" do
    time = Time.now
    a = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar",
                                                         :pid  => 123,
                                                         :process_registries => [ ProcessRegistry.new(:name => "baz1",
                                                                                             :event => "Write",
                                                                                             :time_at => time.to_f,
                                                                                             :value_name => "baz2",
                                                                                             :value_type => "baz3",
                                                                                             :value => "baz4"
                                                                                  ) ]
                                           ) ] )
    assert a.save
    a.reload
    assert_equal a.os_processes.first.process_registry_count, 1, "Process registry count not accurate"

    b = Fingerprint.new(:checksum => "foo",
                        :os_processes => [ OsProcess.new(:name => "bar",
                                                         :pid  => 123,
                                                         :process_registries => [ ProcessRegistry.new(:name => "baz1",
                                                                                             :event => "Write",
                                                                                             :time_at => time.to_f,
                                                                                             :value_name => "baz2",
                                                                                             :value_type => "baz3",
                                                                                             :value => "baz4"
                                                                                  ) ]
                                           ) ] )
    assert b.save, "Can't save duplicate process registry entry"
    b.reload
    assert_equal b.os_processes.first.process_registry_count, 1, "Process registry count not accurate"
  end
end
