defmodule Mips.Pattern do
  @moduledoc """
  Contains functions for formatting the input such as correctly escaping strings and converting int literals from strings
  """

  @spec escape(char::binary()) :: binary
  @spec integer(int::binary) :: integer

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
        x -> throw("Invalid escape: #{x}")
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

  def integer(x) do
    case x do
      <<?0,?x,rest::binary>> -> String.to_integer(rest, 16)
      x -> String.to_integer(x)
    end
  end
end
