defmodule TRAFex do
  alias TRAFex.Log
  @moduledoc """
  Documentation for `TRAFex`.
  """

  @doc """
  Hello world.

  """
  def parse!(contents) when is_binary(contents) do
    TRAFex.Parser.parse_text(contents)
  end

  def flatten(list) do
    list
    |> Enum.map(&flatten_log/1)
    |> List.flatten()
  end

  defp flatten_log(%Log{name: name, records: records}) do
    #add name to each record
    records |> Enum.map(fn record -> Map.put(record, :name, name) end)
  end

end
