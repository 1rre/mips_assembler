defmodule MipsTest do
  use ExUnit.Case


  test "start test" do
    Mips.start()
    |> Mips.write_hexes()
    #Enum.each(fn {data, f_name} ->
    #  IO.puts("\n#{Regex.run(~r/(?<l>.*)\.(s|asm)/, f_name, capture: :all_names)}.hex:")
    #  Enum.each(data, fn [<<x::32>>] -> "0x" <> (Integer.to_string(x, 16) |> String.pad_leading(8, "0")) |> IO.puts end)
    #end)
  end
end
