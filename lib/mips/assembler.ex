defmodule Mips.Assembler do

  #require Mips.Const
  import Mips.Const

  @spec assemble() :: :ok
  @spec read_files() :: list(list(binary()))
  @spec format_file(lines::list(binary())) :: list(binary())
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
    |> Enum.each(fn {f_name, lines} ->
      labels = extract_labels(lines)
      Enum.reject(lines, &String.match?(elem(&1, 0), ~r/[a-z|_]+:/))
      |> Enum.map(fn {line, l_num} ->
        try do
          format_line(line)
          |> Mips.Hex.hex()
        catch
          :throw, [reg_name: reg] -> Mips.Exception.exception([file: f_name, line: l_num, message: "Unrecognised register: #{reg}"])
            |> Exception.message()
            |> exit
          _ -> Mips.Exception.exception([file: f_name, line: l_num, message: "Could not parse '#{line}'"])
            |> Exception.message()
            |> exit
        end
      end)
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
      String.trim(line)
      |> String.replace(~r/#.*\z/, "")
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

  def format_line(line) do
    [op, ar] = String.split(line, " ", parts: 2)
    (String.downcase(op)
    |> String.pad_trailing(7))
    <> (
      String.split(ar, ", ")
      |> Enum.map(fn arg ->
        case arg do
          "$zero" -> <<?$,0::8>>
          <<?$,rest::binary>> when rest not in registers() -> throw([reg_name: <<?$,rest::binary>>])
          <<?$,a::8,b::8>> when a in ?0..?3 -> <<?$,(a-?0)*10+(b-?0)::8>>
          <<?$,a::8>> when a in ?0..?9 -> <<?$,a-?0::8>>
          <<?$,a::16>> -> resolve_reg(a)
          _ -> cond do
          Enum.all?(to_charlist(arg), & &1 in ?0..?9) -> <<String.to_integer(arg)::32>> # Making this 32 bits for data purposes - it will be truncated to 16 bits later for immediate addressing
          String.match?(arg, ~r/0x[[:xdigit:]]+/i) -> <<String.to_integer(String.trim(arg, "0x"), 16)::32>>
          true -> arg
          end
        end
      end)
      |> Enum.join(", ")
    )
  end


  ####################################################################
  # Get the line numbers of each of the labels & store them in a map #

  defp extract_labels(lines) do
    Enum.filter(lines, &String.match?(elem(&1, 0), ~r/[a-z|_]+:/))
    |> Map.new()
  end

end
