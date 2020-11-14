defmodule MipsTest do
  use ExUnit.Case
  doctest Mips

  test "add test" do
    [<<hex::32>>] = Mips.Hex.hex(Mips.Assembler.format_line("add $t0, $t4, $t3"))
    assert hex == 0x018B4020
  end

  test "sll test" do
    [<<hex::32>>] = Mips.Hex.hex(Mips.Assembler.format_line("sll $8, $t4, 14"))
    assert hex == 0x000C4380
  end

  test "srl test" do
    [<<hex::32>>] = Mips.Hex.hex(Mips.Assembler.format_line("srl $t0, $zero, 0x4"))
    assert hex == 0x00004102
  end

  test "or test" do
    [<<hex::32>>] = Mips.Hex.hex(Mips.Assembler.format_line("or $t0, $t4, $t3"))
    assert hex == 0x018B4025
  end

  test "bitstring test" do
    <<bits::4>> = 0b11010111
    assert bits == 0b0111
  end

  test "start test" do
    Mips.start()
    :ok
  end
end
