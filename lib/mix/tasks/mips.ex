defmodule Mix.Tasks.Mips do
  use Mix.Task
  def main(input), do: run(input)

  def run([file]) do
    input = File.read!(file)
    {:ok, res, _, _, _, _} = Mips.Parser.program(input)
    out_file = file <> ".bin"
    File.write!(out_file, res)
  end
  def run([]) do
    res = Mips.Parser.program(".ascii \"hello world!\"")
    :io.fwrite("~p~n", [res])
  end
end
