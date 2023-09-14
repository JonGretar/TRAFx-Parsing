defmodule TRAFex.Parser do
  alias TRAFex.Log

  @spec parse_text(binary) :: list
  def parse_text(text) do
    text
    |> String.split("Counter log start")
    |> Enum.drop(1)
    |> Enum.map(&parse_log/1)
  end

  defp parse_log(log) do
    log
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(%Log{}, &parse_line/2)
  end

  defp parse_line("*Counter name   :" <> name, state) do
    %{state | name: name}
  end

  defp parse_line("*Serial Number  :" <> serial, state) do
    %{state | serial: serial}
  end

  defp parse_line("*Mode           :" <> mode, state) do
    %{state | mode: mode}
  end

  defp parse_line("*Batt. voltage  :" <> volt, state) do
    %{state | voltage: volt}
  end

  defp parse_line("*Stored records :" <> records, state) do
    %{state | stored_records: String.to_integer(records)}
  end

  defp parse_line("=TIME (yy-mm-dd hh:mm):" <> timestamp, state) do
    datetime = "20"<>timestamp
      |> String.replace(",", "T")
      |> NaiveDateTime.from_iso8601!()
    %{state | time: datetime}
  end

  defp parse_line("=START(yy-mm-dd hh:mm):" <> timestamp, state) do
    datetime = "20"<>timestamp<>":00"
      |> String.replace(",", "T")
      |> NaiveDateTime.from_iso8601!()
    %{state | start: datetime}
  end

  defp parse_line("PERIOD (1/24/0=Timestamps) :" <> period, state) do
    %{state | period: String.to_integer(period)}
  end

  defp parse_line("DELAY     (see manual)     :" <> delay, state) do
    %{state | delay: String.to_integer(delay)}
  end

  defp parse_line("THRESHOLD (see manual)     :" <> threshold, state) do
    %{state | threshold: String.to_integer(threshold)}
  end

  defp parse_line("RATE (Fast/Slow)           :" <> rate, state) do
    %{state | rate: rate}
  end

  defp parse_line(
         <<date::binary-size(8), ",", time::binary-size(5), ",", count::binary-size(5)>>,
         state = %Log{records: records}
    ) do
    date = Date.from_iso8601!("20#{date}")
    time = Time.from_iso8601!("#{time}:00")
    %{state | records: [%{date: date, time: time, count: String.to_integer(count)} | records]}
  end

  defp parse_line(_line, state) do
    # IO.puts("Unknown line: #{line}")
    state
  end

end
