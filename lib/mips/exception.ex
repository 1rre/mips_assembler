defmodule Mips.Exception do
  @spec raise([file: f_name::binary(), line: l_num::integer(), message: message::binary()]) :: nil
  defexception [:file, :line, message: "Syntax error in MIPS code"]

  @impl true
  def message(%{file: file, line: line, message: message}) do
    Exception.format_file_line(file, line) <> " " <> message
  end
  def raise([file: file, line: line, message: message]) do
    exception([file: file, line: line, message: message])
    |> reraise([])
  end
end
