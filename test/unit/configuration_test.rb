require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  test "should not save configuration without name, value, and namespace" do
    c = Configuration.new
    assert !c.save, "Saved configuration without name, value, and namespace"
  end

  test "should not save duplicate configurations" do
    a = Configuration.new(:name      => "foo",
                          :value     => "bar",
                          :namespace => "baz")
    assert a.save

    b = Configuration.new(:name      => "foo",
                          :value     => "bar",
                          :namespace => "baz")
    assert !b.save, "Saved duplicate configuration entry"
  end
end
