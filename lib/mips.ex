defmodule Mips do
  @spec start :: any()#:ok
  @spec write_hexes(list({m_code::[<<_::32>>], f_name::binary()})) :: :ok

  def start do
    File.cd!(:code.priv_dir(:mips))
    Enum.each(["0-assembly", "1-hex"], &File.mkdir(&1))
    Mips.Assembler.assemble
  end

  ################################################################
  # Take a list of assembled files and output them in hex format #

  # Will be private & called by start once testing is completed

  def write_hexes(hexes) do
    File.cd!("1-hex", fn ->
      Enum.each(hexes, fn {m_code, f_name} ->
        String.replace(f_name, ~r/\.(asm|s)\z/, ".hex")
        |> File.write!(m_code, [:raw])
      end)
    end)
  end
end
