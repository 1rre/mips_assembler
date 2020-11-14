defmodule Mips do
  @spec start :: :ok
  @spec make_files :: :ok


  def start do
    File.cd!(:code.priv_dir(:mips))
    make_files()
    Mips.Assembler.assemble
  end

  def make_files do
    Enum.each(["0-assembly", "1-hex"], &try do File.touch!(&1) rescue _ -> File.mkdir!("0-assembly") end)
  end
end
