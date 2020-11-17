defmodule Mips.Pattern do
  @moduledoc """
  Contains functions for formatting the input such as correctly escaping strings and converting int literals from strings
  """

  @spec escape(char::binary)  :: binary
  @spec integer(int::binary)  :: integer
  @spec register(reg::binary) :: integer


  @doc """
  Replace a character escaped with a backslash with its escape character.
  ### Inputs:
    A string containing 0 or more valid escaped characters
  ### Outputs:
    The string with the escape characters correctly formatted.
  """

  def escape(x) do
    String.replace(x, ~r/(\\([0-7]){3})|(\\x([[:xdigit:]]){2})|(\\.)/, fn <<?\\,rest::binary>> ->
      case rest do
        "a" -> "\a"
        "b" -> "\n"
        "e" -> "\e"
        "f" -> "\f"
        "n" -> "\n"
        "r" -> "\r"
        "t" -> "\t"
        "v" -> "\v"
        "\\"-> "\\"
        "'" -> "\'"
        "\""-> "\""
        "?" -> "\?"
        <<?x,a::8,b::8>> -> <<a-?0::4,b-?0::4>>
        <<x::8,y::8,z::8>> when x <= ?3 -> <<x-?0::2,y-?0::3,z-?0::3>>
        x -> throw("Invalid escape: '\\#{x}'")
      end
    end)
  end


  @doc """
  Convert a hexidecimal or decimal string to an integer representation
  ### Inputs:
    A valid hexadecimal or decimal integer in string form
  ### Outputs:
    The string converted to an integer.
  """

  def integer(<<?0,?x,rest::binary>>), do: String.to_integer(rest, 16)
  def integer(x), do: String.to_integer(x)


  @doc """
  Resolves a register in string form to its integer value for use in hex ops
  """

  def register(<<?$,x::8,y::8>>) when x in ?1..?2 and y in ?0..?9, do: (x - ?0) * 10 + y - ?0
  def register(<<?$,?v,x::8>>) when x in ?0..?1, do: x - ?0 + 2
  def register(<<?$,?a,x::8>>) when x in ?0..?3, do: x - ?0 + 4
  def register(<<?$,?t,x::8>>) when x in ?0..?7, do: x - ?0 + 8
  def register(<<?$,?s,x::8>>) when x in ?0..?7, do: x - ?0 + 16
  def register(<<?$,?t,x::8>>) when x in ?8..?9, do: x - ?0 + 24
  def register(<<?$,?k,x::8>>) when x in ?0..?1, do: x - ?0 + 26
  def register(<<?$,?3,x::8>>) when x in ?0..?1, do: x - ?0 + 30
  def register(<<?$,x::8>>) when x in ?0..?9, do: (x - ?0)
  def register("$zero"), do: 0
  def register("$at"), do: 1
  def register("$gp"), do: 28
  def register("$sp"), do: 29
  def register("$s8"), do: 30
  def register("$ra"), do: 31
  def register(x), do: throw {:register, x}
end
