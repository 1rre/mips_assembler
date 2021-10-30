defmodule Mix.Tasks.Mips do
  use Mix.Task
  def run([file]) do
    input = File.read!(file)
    {:ok, res, _, _, _, _} = Mips.Parser.program(input)
    out_file = file <> ".bin"
    File.write!(out_file, res)
  end
end
