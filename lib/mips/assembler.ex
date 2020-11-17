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
      {:mem, op} -> op
      %{align: to} -> %{align: to}
      op ->
        try do
          Regex.run(~r/(?<a>([^\s]+))(\s((?<ar0>([^,]+))(,\s(?<ar1>([^,]+))(,\s(?<ar2>([^,]+)))?)?)?)?/, op, capture: :all_names)
          |> List.update_at(0, &String.downcase/1)
          |> Enum.reject(&""==&1)
          |> resolve_instruction(labels)
        catch
          :throw, {:instr, instr} ->
            ln = Enum.find(lines, {nil, ""}, fn {txt, _} -> String.contains?(txt, instr) end)
            |> elem(1)
            Mips.Exception.raise(file: f_name, line: ln, message: "Invalid instruction #{instr}")
          :throw, {:offset, int} ->
            ln = Enum.find(lines, {nil, ""}, fn {txt, _} -> String.contains?(txt, int) end)
            |> elem(1)
            Mips.Exception.raise(file: f_name, line: ln, message: "Invalid offset #{int}. Offsets should be a valid label or offset.")
          :throw, {:register, reg} ->
            ln = Enum.find(lines, {nil, ""}, fn {txt, _} -> String.contains?(txt, reg) end)
            |> elem(1)
            Mips.Exception.raise(file: f_name, line: ln, message: "Invalid register #{reg}")
          :throw, label ->
            IO.puts(label)
            ln = Enum.find(lines, {nil, ""}, fn {txt, _} -> String.contains?(txt, label) end)
            |> elem(1)
            Mips.Exception.raise(file: f_name, line: ln, message: "Label '#{label}' was not found.")
        end
      end
    ) |> Enum.reduce(<<>>, fn
      %{align: to}, acc ->
        size = (to * ceil(byte_size(acc) / to)) * 8 - bit_size(acc)
        <<acc::bits, 0::size(size)>>
      v, acc -> <<acc::bits, v::bits>>
      end
    )
    |> write_hex(f_name)
  end

  defp write_hex(m_code, f_name) do
    File.cd!("1-hex", fn ->
      String.replace(f_name, ~r/\.(asm|s)\z/, ".hex")
      |> File.write!(m_code, [:raw])
    end)
  end


  defp expand_early(lines) do
    earlies = Enum.map(lines, fn {line, l_num} ->
      {if Regex.match?(~r/[a-z|_]+:.*/, line) do
        [header, op] = String.split(line, ": ")
        try do
          case resolve_early(op) do
            x when is_list(x) -> List.update_at(x, 0, &{header,&1})
            x -> {header, x}
          end
        catch
          :throw, reason -> throw {l_num, reason}
        end
      else
        resolve_early(line)
      end, l_num}
    end)
    |> List.flatten()
    {Enum.map(earlies, fn {{_, x}, l_num} -> {x, l_num}; x -> x end), Enum.reduce(earlies, {%{}, 0}, fn
      {header, {{:mem, x}, l_num}}, {map, acc} when is_bitstring(x) ->
        if Map.has_key?(map, header) do
          throw {:header, header, l_num}
        else
          {Map.put(map, header, acc), acc + byte_size(x)}
        end
      {header, {%{align: to}, l_num}}, {map, acc} ->
        if Map.has_key?(map, header) do
          throw {:header, header, l_num}
        else
          {Map.put(map, header, acc), to * ceil(acc / to)}
        end
      {header, {_, l_num}}, {map, acc} ->
        if Map.has_key?(map, header) do
          throw {:header, header, l_num}
        else
          {Map.put(map, header, acc), acc + 4}
        end
      {x,_}, {map, acc} when is_bitstring(x) -> {map, acc + byte_size(x)}
      _, {map, acc} -> {map, acc + 4}
      {%{align: to},_}, {map, acc} ->  {map, to * ceil(acc / to)}
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
