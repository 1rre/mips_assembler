defmodule Mips.Assembler do
  import Mips.Const

  @spec assemble() :: list(<<_::32>>)
  @spec read_files() :: list(list(binary()))
  @spec format_file(lines::list(binary())) :: list(binary())
  @spec format_line(line::binary)::bitstring()
  @spec extract_labels(list({line::binary(), index::integer()})) :: %{{binary(), integer()} => {binary(), integer()}}

  @doc """
    Run the assembler on each .s or .asm file, converting it to MIPS machine code.

    ### Input:
    Any file containing MIPS assembly in `/priv/0-assembly/` ending with .asm or .s
    ### Output:
    MIPS machine code is added to `/priv/1-hex/` with the extension changed to .hex
  """

  def assemble do
    read_files()
    |> Enum.map(fn {f_name, lines} -> # Change back to each when debugging complete
      labels = extract_labels(lines)
      {Enum.reject(lines, &String.match?(elem(&1, 0), ~r/[a-z|_]+:/))
      |> Enum.map(fn {line, l_num} ->
        try do
          format_line(line)
          |> Mips.Hex.hex()
        catch
          :throw, [reg_name: reg] -> Mips.Exception.exception([file: f_name, line: l_num, message: "Unrecognised register: #{reg}"])
            |> raise
          _ -> Mips.Exception.exception([file: f_name, line: l_num, message: "Unrecognised instruction '#{line}'"])
            |> Exception.message()
            |> raise
        end
      end), f_name}
    end)
  end


  #############################################################
  # Read all files ending with .asm or .s in /priv/0-assembly #

  defp read_files do
    File.cd!("0-assembly", fn ->
      File.ls!
      |> Enum.filter(&Regex.match?(~r/.+\.(asm|s)/, &1))
      |> Enum.map(fn f_name ->
        {f_name, File.read!(f_name)
          |> String.split(~r/[[:space:]]*\n[[:space:]]*/)
          |> Enum.with_index(1)
          |> format_file()}
      end)
    end)
  end


  #####################################################################
  # Format the file nicely to make pattern matching operations easier #

  defp format_file(lines) do
    Enum.map(lines, fn {line, i} ->
      String.replace(line, ~r/#.*\z/, "")
      |> String.trim()
      |> String.replace(~r/[[:space:]]+/, " ")
      |> String.replace(~r/\A(?<_>[a-z|_]+):\s/im,"\\g{1}:\n")
      |> String.replace(~r/[[:blank:]]?,[[:blank:]]?/, ",\s")
      |> String.split("\n")
      |> Enum.zip([i,i])
    end)
    |> List.flatten()
    |> Enum.reject(&elem(&1, 0) == "")
  end


  ##############################################################################################
  # Format the line by converting to lowercase (except labels) and registers to their bitfield #

  defp format_line(op) when op in op_1(), do: String.downcase(op)
  defp format_line(line) do
    l_arr = String.split(line, " ", parts: 2)
    if length(l_arr) < 2, do: throw("")
    [op, ar] = l_arr
    (String.downcase(op)
    |> String.pad_trailing(7))
    <> (
      String.split(ar, ", ")
      |> Enum.map(fn arg ->
        case arg do
          "$zero" -> <<0::8>>
          <<?$,rest::binary>> when rest not in registers() -> throw([reg_name: <<?$,rest::binary>>])
          <<?$,a::8,b::8>> when a in ?0..?2 or a == ?3 and b in ?0..?1 -> <<(a-?0)*10+(b-?0)::8>>
          <<?$,a::8>> when a in ?0..?9 -> <<a-?0::8>>
          <<?$,a::16>> -> resolve_reg(a)
          _ -> cond do
          Enum.all?(to_charlist(arg), & &1 in ?0..?9) -> <<String.to_integer(arg)::32>>
          String.match?(arg, ~r/0x[[:xdigit:]]+/i) -> <<String.to_integer(String.trim(arg, "0x"), 16)::32>>
          true -> arg
          end
        end
      end)
      |> Enum.join()
    )
  end


  ####################################################################
  # Get the line numbers of each of the labels & store them in a map #

  defp extract_labels(lines) do
    Enum.filter(lines, &String.match?(elem(&1, 0), ~r/[a-z|_]+:/))
    |> Map.new()
  end

end
