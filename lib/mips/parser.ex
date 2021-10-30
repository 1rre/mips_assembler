defmodule Mips.Parser do
  import NimbleParsec

  defmodule Helpers do
    def parse_rtype(name, code) do
      ignore(string(name))
      |> parsec(:ws)
      |> parsec(:arg3reg)
      |> reduce({:rtype_gen, [code]})
    end
    def parse_shift(name, code) do
      ignore(string(name))
      |> parsec(:ws)
      |> parsec(:arg2reg)
      |> reduce({:shift_gen, [code]})
    end
    def parse_itype(name, code) do
      ignore(string(name))
      |> parsec(:ws)
      |> parsec(:arg2reg)
      |> reduce({:itype_gen, [code]})
    end
    def parse_jtype(name, code) do
      ignore(string(name))
    end
  end

  lower_case = ?a..?z
  upper_case = ?A..?z
  digit = ?0..?9

  defparsecp(:id_char, ascii_char([lower_case, upper_case, digit, ?_, ?$]))
  defparsecp(:comment, ascii_char([?#]) |> eventually(ascii_char([?\n])))
  defparsecp(:whitespace, ascii_char([?\s, ?\n, ?\t, ?\r]))
  defparsecp(:ws, ignore(repeat(choice([parsec(:whitespace), parsec(:comment)]))))
  defparsecp(:reg, ignore(ascii_char([?$])) |> integer(min: 0, max: 31))

  defparsec(:label,
    repeat(parsec(:id_char))
    |> string(":")
    |> reduce(:to_string)
  )

  defparsec(:arg3reg,
    parsec(:reg)
    |> parsec(:ws)
    |> parsec(:reg)
    |> parsec(:ws)
    |> parsec(:reg)
  )
  defparsec(:arg2reg,
    parsec(:reg)
    |> parsec(:ws)
    |> parsec(:reg)
    |> parsec(:ws)
    |> integer(min: 0)
  )
  def jtype_gen([addr], code) do
    <<code::6, addr::26>>
  end
  def itype_gen([rt, rs, im], code) do
    <<code::6, rs::5, rt::5, im::16>>
  end
  def rtype_gen([rd, rs, rt], code) do
    <<0::6, rs::5, rt::5, rd::5, 0::5, code::6>>
  end
  def shift_gen([rd, rt, shift], code) do
    <<0::6, 0::5, rt::5, rd::5, shift::5, code::6>>
  end

  defparsecp(:instr, choice([
    Helpers.parse_rtype("add",   0b100000),
    Helpers.parse_itype("addi",  0b001000),
    Helpers.parse_itype("addiu", 0b001001),
    Helpers.parse_rtype("addu",  0b100001),
    Helpers.parse_rtype("and",   0b100100),
    Helpers.parse_itype("andi",  0b001100),
  ]))
  defparsec(:program, repeat(parsec(:instr) |> parsec(:ws)))

end
