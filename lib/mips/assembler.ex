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

#    {data, text} = Enum.chunk_by(lines, &(elem(&1, 0) in [".data",".text"]))
#    |> Enum.chunk_every(2)
#    |> Enum.split_with(&hd(&1) |> hd() |> elem(0) == ".data")

    {_,text,data} = Enum.reduce(lines, {true,[],[]}, fn
      {<<".globl ", _::bits>>,_}, {x,text,data} -> {x,text,data}
      {<<".global ",_::bits>>,_}, {x,text,data} -> {x,text,data}
      {".data",_}, {_,text,data} -> {false,text,data}
      {".text",_}, {_,text,data} -> {true ,text,data}
      line, {true, text,data} -> {true ,[line|text],data}
      line, {false,text,data} -> {false,text,[line|data]}
    end)
    # Because of how Elixir/Erlang handles lists, it's faster to assemble the list back to front then reverse them.
    {text,data} = {Enum.reverse(text),Enum.reverse(data)}

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
        ])
    end

    0

  end
  ##########################################################################################################################
  # As we don't know if our input is going to be in SPIM or MIPS format, this converts both data and instructions to hex." #

  defp assemble_text(text) do
    Enum.map(text, fn {line, l_num} ->
      if Regex.match?(~r/[a-z|_]+:.*/, line) do
        [header, op] = String.split(line, ": ")
        case resolve_early(op) do
          x when is_list(x) -> List.update_at(x, 0, &{header,&1})
          x when is_bitstring(x) -> {header, x}
        end
      else
        resolve_early(line)
      end
    end)
  end

  #####################################################################################################
  # Convert data directives to their hex representation. These will be appended to the end of the hex #

  defp assemble_data(data) do
    Enum.map(data, fn
      {<<".align ", rest::binary>>, l_num} ->
        try do
          resolve_early(".align "<>rest)
        catch
          :throw, reason -> throw {l_num, reason}
        end
      {<<".space ", rest::binary>>, l_num} ->
        try do
          resolve_early(".space "<>rest)
        catch
          :throw, reason -> throw {l_num, reason}
        end
      {<<?., rest::binary>>, l_num} ->
        try do
          resolve_early("."<>rest)
        catch
          :throw, reason -> throw {l_num, reason}
        end
      {str, l_num} ->
        try do
          [header, dat] = String.split(str, ": ")
          {header, resolve_early(dat), l_num}
        catch
          :throw, reason -> throw {l_num, reason}
          _,_ -> throw {l_num, "Error parsing '#{str}' as data"}
        end
      end
    )
    |> List.flatten
    |> Enum.reduce({%{}, <<>>}, fn
      %{align: to}, {map, acc}  ->
        size = 8 * (to - Integer.mod(byte_size(acc), to))
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
      |> Enum.filter(&Regex.match?(~r/.+\.(asm|s)\z/, &1))
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
