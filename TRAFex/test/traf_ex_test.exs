defmodule TRAFexTest do
  use ExUnit.Case
  alias TRAFex.Log
  doctest TRAFex

  test "Reads the counter name" do
    content = "Junk\nCounter log start\n \n  *Counter name   :Counter\nAnotherdata"
    data = TRAFex.Parser.parse_text(content)
    assert data == [%Log{name: "Counter"}]
  end

  test "Reads 3 counters" do
    file_content = File.read!("priv/trafx-test-short.txt")
    data = TRAFex.Parser.parse_text(file_content)
    assert length(data) == 3
  end

  test "Flatten the map" do
    file_content = File.read!("priv/trafx-test-short.txt")
    data = TRAFex.Parser.parse_text(file_content)
    flat = TRAFex.flatten(data)
    assert length(flat) == 30
  end

end
