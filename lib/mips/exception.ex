defmodule Mips.Exception do
  defexception [:file, :line, message: "Syntax error in MIPS code"]

  @impl true
  def message(%{file: file, line: line, message: message}) do
    Exception.format_file_line(file, line) <> " " <> message
  end
end
