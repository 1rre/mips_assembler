defmodule Mips do

  def start do
    File.cd!(:code.priv_dir(:mips))
    Enum.each(["0-assembly", "1-hex"], &File.mkdir(&1))
    Mips.Assembler.assemble
  end

end
