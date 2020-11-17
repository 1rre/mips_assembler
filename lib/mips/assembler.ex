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

    {_,text,data} = Enum.reduce(lines, {true,[],[]}, fn
      {<<".globl ", _::bits>>,_}, {x,text,data} -> {x,text,data}
      {<<".global ",_::bits>>,_}, {x,text,data} -> {x,text,data}
      {".data",_}, {_,text,data} -> {false,text,data}
      {".text",_}, {_,text,data} -> {true ,text,data}
      line, {true, text,data} -> {true ,[line|text],data}
      line, {false,text,data} -> {false,text,[line|data]}
    end)
    # Because of how Elixir/Erlang handles lists, it's faster to assemble the list back to front then reverse them.
    content = Enum.reverse(text) ++ Enum.reverse(data)


    {instructions, labels} = try do
      expand_early(content)
     catch
      :throw, {l_num, reason} -> Mips.Exception.raise(file: f_name, line: l_num, message: reason)
      :throw, label ->
        lns = Enum.filter(lines, fn {txt, _} -> String.contains?(txt, label <> ":") end)
        |> Enum.map(&elem(&1, 1))
        Mips.Exception.raise(file: f_name, line: hd(lns), message: "Label '#{label} declared multiple times on lines: #{Enum.join(lns, ", ")}")
    end
    Enum.map(instructions, fn
      op when is_bitstring(op) -> op
      %{align: to} -> %{align: to}
      op ->
        try do
          resolve_instruction(op, labels)
        catch
          :throw, label ->
            ln = Enum.find(lines, {nil, ""}, fn {txt, _} -> String.contains?(txt, label) end)
            |> elem(1)
            Mips.Exception.raise(file: f_name, line: ln, message: "Label '#{label} was not found.")
        end
      end
    ) |> Enum.reduce(<<>>, fn
      %{align: to}, acc ->
        size = to * 8 * ceil(byte_size(acc) / (to * 8)) - byte_size(acc)
        <<acc::bits, 0::size(size)>>
      v, acc -> <<acc::bits, v::bits>>
      end
    )
  end


  defp expand_early(lines) do
    earlies = Enum.map(lines, fn {line, l_num} ->
      if Regex.match?(~r/[a-z|_]+:.*/, line) do
        [header, op] = String.split(line, ": ")
        try do
          case resolve_early(op) do
            x when is_list(x) -> List.update_at(x, 0, &{header,&1})
            x when is_bitstring(x) -> {header, x}
          end
        catch
          :throw, reason -> throw {l_num, reason}
        end
      else
        resolve_early(line)
      end
    end)
    |> List.flatten()
    {Enum.map(earlies, fn {_, x} -> x; x -> x end), Enum.reduce(earlies, {%{}, 0}, fn
      {header, x}, {map, acc} when is_bitstring(x) ->
        if Map.has_key?(map, header) do
          throw header
        else
          {Map.put(map, header, acc), acc + byte_size(x)}
        end
      {header, %{align: to}}, {map, acc} ->
        if Map.has_key?(map, header) do
          throw header
        else
          {Map.put(map, header, acc), to * 8 * ceil(acc / (to * 8))}
        end
      {header, _}, {map, acc} ->
        if Map.has_key?(map, header) do
          throw header
        else
          {Map.put(map, header, acc), acc + 4}
        end
      x, {map, acc} when is_bitstring(x) -> {map, acc + byte_size(x)}
      _, {map, acc} -> {map, acc + 4}
      %{align: to}, {map, acc} ->  {map, to * 8 * ceil(acc / (to * 8))}
      end
    ) |> elem(0)}
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
