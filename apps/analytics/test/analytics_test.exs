defmodule AnalyticsTest do
  use ExUnit.Case
  doctest Analytics

  test "greets the world" do
    assert Analytics.hello() == :world
  end
end
