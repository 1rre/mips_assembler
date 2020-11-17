defmodule Mix.Tasks.Mips do
  use Mix.Task
  @spec run(any) :: :ok
  @spec main(any) :: :ok

  def main(_) do
    if !File.exists?("resources"), do: File.mkdir!("resources")
    File.cd!("resources")
    Enum.each(["0-assembly", "1-hex"], &File.mkdir(&1))
    Mips.Assembler.assemble
  end
  def run(x), do: main(x)
end
