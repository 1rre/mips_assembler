defmodule Mips.Assembler do
  import Mips.Resolvers

  @spec assemble() :: list(<<_::32>>)
  @spec read_files() :: list(list(binary()))
  @spec format_file(lines::list(binary())) :: list(binary())

  @doc """
    Run the assembler on each .s or .asm file, converting it to MIPS machine code.

    ### Input:
    Any file containing MIPS assembly in `/priv/0-assembly/` ending with .asm or .s
    ### Output:
    An array containing lists of MIPS machine code in pure hexidecimal form & the corresponding file names.
  """

  def assemble do
    read_files()
    |> Enum.map(&assemble_file/1)
  end

  ###################################################
  # Assemble a single file containing mips assembly #

  defp assemble_file({f_name, lines}) do

    {data, text} = Enum.chunk_by(lines, &(elem(&1, 0) in [".data",".text"]))
    |> Enum.chunk_every(2)
    |> Enum.split_with(&hd(&1) |> hd() |> elem(0) == ".data")

    {data_labels, data_hex} = try do
      assemble_data(data)
    catch
      :throw, {l_num, reason} ->
        Mips.Exception.raise([file: f_name, line: l_num, message: reason])
    end

    {text_labels, text_hex} = try do
      assemble_text(text)
      {%{}, <<>>}
     catch
      :throw, {l_num, reason} ->
        Mips.Exception.raise([file: f_name, line: l_num, message: reason])
    end

    case Map.keys(data_labels) ++ Map.keys(text_labels) |> Enum.frequencies |> Enum.max_by(&elem(&1, 1), fn -> {nil, 1} end) do
      {_, 1} -> :ok
      {label, _} ->
        d_pos = Enum.find(data, 0, fn {_, line} -> String.contains?(line, label) end) |> elem(0)
        t_pos = Enum.find(text, 0, fn {_, line} -> String.contains?(line, label) end) |> elem(0)
        Mips.Exception.raise([
          file: f_name,
          line: max(d_pos, t_pos),
          message: "Label #{label} declared twice, first declared on line #{min(d_pos, t_pos)}"
        ]) |> exit()
    end

    0
  end

  ##########################################################################################################################
  # As we don't know if our input is going to be in SPIM or MIPS format, this converts both data and instructions to hex." #

  defp assemble_text(text) do
    Enum.map(text, fn
      [[{".text", _}]] -> {%{}, <<>>}
      [[{".text", _}], instr] -> Enum.map(instr, fn
        {op, l_num} ->
          try do
            resolve_op(op)
          catch
            :throw, reason -> throw {l_num, reason}
          end
      end)
      [instr] -> Enum.map(instr, fn
        {".data", l_num} ->
          throw({l_num, "Unexpected data declaration (did you forget to use .text or .data at the start of your program?)"})
        {".text", l_num} ->
          throw({l_num, "Unexpected text declaration (did you forget to use .text or .data at the start of your program)"})
        {op, l_num} -> :ok
      end)
      [_, [{what, l_num}]] ->
        throw({l_num, "Unexpected #{what} (did you forget to use .text or .data at the start of your program?)"})
    end)
  end

  #####################################################################################################
  # Convert data directives to their hex representation. These will be appended to the end of the hex #

  defp assemble_data(data) do
    Enum.map(data, fn [_, dec] ->
      Enum.map(dec, fn
        {<<".align ", rest::binary>>, l_num} ->
          try do
            resolve_data(".align "<>rest)
          catch
            :throw, reason -> throw {l_num, reason}
          end
        {<<".space ", rest::binary>>, l_num} ->
          try do
            resolve_data(".space "<>rest)
          catch
            :throw, reason -> throw {l_num, reason}
          end
        {str, l_num} ->
          try do
            [header, dat] = String.split(str, ": ")
            {header, resolve_data(dat), l_num}
          catch
            :throw, reason -> throw {l_num, reason}
            _,_ -> throw {l_num, "Error parsing '#{str}' as data"}
          end
        end
      )
    end)
    |> List.flatten
    |> Enum.reduce({%{}, <<>>}, fn
      %{align: to}, {map, acc}  ->
        size = Integer.mod(to - byte_size(acc), to)
        {map, <<acc::bits, 0::size(size)>>}
      {label, data, l_num}, {map, acc} ->
        if Map.has_key?(map, label),
        do: throw({l_num, "Duplicate label '#{label}'"}),
        else: {Map.put(map, label, byte_size(acc)), <<acc::bits, data::bits>>}
      data, {map, acc} -> {map, <<acc::bits, data::bits>>}
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
          |> String.replace(~r/(?<_>[a-z|_]+):([[:space:]]*)/im,"\\g{1}:\s")
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
      |> String.replace(~r/[[:blank:]]?,[[:blank:]]?/, ",\s")
      |> String.split("\n")
      |> Enum.zip([i,i])
    end)
    |> List.flatten()
    |> Enum.reject(&elem(&1, 0) == "")
  end

end
