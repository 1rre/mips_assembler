defmodule Mips do
  @spec start :: :ok
  @spec make_files :: :ok


  def start do
    File.cd!(:code.priv_dir(:mips))
    make_files()
    Mips.Assembler.assemble
  end

  def make_files do
    Enum.each(["0-assembly", "1-hex"], &File.mkdir(&1))
  end
end
