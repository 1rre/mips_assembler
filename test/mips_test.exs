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
    assert hex == 0x00004101
  end

  test "or test" do
    [<<hex::32>>] = Mips.Hex.hex(Mips.Assembler.format_line("or $t0, $t4, $t3"))
    assert hex == 0x018B4025
  end

  test "registers" do
    import Mips.Const
    <<t0::16>> = "t0"
    <<t1::16>> = "t1"
    <<t2::16>> = "t2"
    <<t3::16>> = "t3"
    <<t4::16>> = "t4"
    <<t5::16>> = "t5"
    <<t6::16>> = "t6"
    <<t7::16>> = "t7"
    <<?$, a0::8>> = resolve_reg(t0)
    <<?$, a1::8>> = resolve_reg(t1)
    <<?$, a2::8>> = resolve_reg(t2)
    <<?$, a3::8>> = resolve_reg(t3)
    <<?$, a4::8>> = resolve_reg(t4)
    <<?$, a5::8>> = resolve_reg(t5)
    <<?$, a6::8>> = resolve_reg(t6)
    <<?$, a7::8>> = resolve_reg(t7)
    assert a0 == 0b01000
    assert a1 == 0b01001
    assert a2 == 0b01010
    assert a3 == 0b01011
    assert a4 == 0b01100
    assert a5 == 0b01101
    assert a6 == 0b01110
    assert a7 == 0b01111
  end


  #test "start test" do
  #  Mips.start()
  #  :ok
  #end
end
