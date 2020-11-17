defmodule Mix.Tasks.Mips do
  use Mix.Task
  @spec run(any) :: :ok

  def run(_) do
    File.cd!(:code.priv_dir(:mips))
    Enum.each(["0-assembly", "1-hex"], &File.mkdir(&1))
    Mips.Assembler.assemble
  end
end
