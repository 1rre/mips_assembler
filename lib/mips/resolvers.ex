defmodule Mips.Resolvers do
  import Mips.Pattern
  @spec resolve_data(data::bitstring()) :: bitstring()
  @spec resolve_pseudo([binary]) :: list(binary)
  @spec resolve_early(inst::binary) :: list(binary) | bitstring()

  def resolve_instruction(op, labels) do
    _ = labels
    IO.puts(op)
    <<op>>
  end

  # Null terminated string #
  defp resolve_data(<<".asciiz ", rest::binary>>) do
    s_r = ~r/\A\"(?<s>[^"]*)\"\z/
    Regex.run(s_r, rest, capture: :all_names)
    |> case do
      [x] ->
        try do
          escape(x)
        catch
          :throw, invalid -> throw("#{rest} is not a valid string. Reason: #{invalid}.")
        end
        len_x = String.length(x)
        String.pad_trailing(x, rem(len_x, 4) + len_x + 4, [<<0::8>>])
      nil -> throw("'#{rest}' is not a valid string. Reason: Quote syntax incorrect.")
    end
  end

  # Regular string #
  defp resolve_data(<<".ascii ", rest::binary>>) do
    s_r = ~r/\A\"(?<s>[^"]*)\"\z/
    Regex.run(s_r, rest, capture: :all_names)
    |> case do
      [x] ->
        try do
          escape(x)
        catch
          :throw, invalid -> throw "#{rest} is not a valid string. Reason: #{invalid}."
        end
        len_x = String.length(x)
        String.pad_trailing(x, rem(len_x, 4) + len_x, [<<0::8>>])
      nil -> throw "'#{rest}' is not a valid string. Reason: Quote syntax incorrect."
    end
  end

  # 8 bits #
  defp resolve_data(<<".byte ", rest::binary()>>) do
    String.split(rest, ", ")
    |> Enum.map(&
      try do
        case integer(&1) do
          x when x in 0..255 -> x
          x -> IO.warn("#{&1} truncated to 8 bits", []); x
        end
      catch
        _,_ -> throw "Invalid byte literal: #{&1}"
      end
    )
    |> Enum.into(<<>>, &<<&1::8>>)
  end

  # 16 bits #
  defp resolve_data(<<".half ", rest::binary()>>) do
    String.split(rest, ", ")
    |> Enum.map(&
      try do
        case integer(&1) do
          x when x in 0..65535 -> x
          x -> IO.warn("#{&1} truncated to 16 bits", []); x
        end
      catch
        _,_ -> throw "Invalid half literal: #{&1}"
      end
    )
    |> Enum.into(<<>>, &<<&1::16>>)
  end

  # 32 bits #
  defp resolve_data(<<".word ", rest::binary()>>) do
    String.split(rest, ", ")
    |> Enum.map(&
      try do
        case integer(&1) do
          x when x in 0..4294967295 -> x
          x -> IO.warn("#{&1} truncated to 32 bits", []); x
        end
      catch
        _,_ -> throw "Invalid word literal: #{&1}"
      end
    )
    |> Enum.into(<<>>, &<<&1::32>>)
  end

  # Reserved space #
  defp resolve_data(<<".space ", rest::binary>>) do
    size = try do
      integer(rest)
      |> pow_2()
    catch
        _,_ -> throw "Invalid integer literal: #{rest}"
    end
    <<0::size(size)>>
  end

  # Align (resolved later) "
  defp resolve_data(<<".align ", rest::binary>>) do
    size = try do
      integer(rest)
      |> pow_2()
    catch
        _,_ -> throw "Invalid integer literal: #{rest}"
    end
    %{align: size}
  end



  defp resolve_pseudo([r0, r1, "abs"]), do: ["addu #{r0}, #{r1}, $0", "bgez #{2}, 8", "sub #{r0}, #{r1}, $0"]
  defp resolve_pseudo([r0, r1, label, "blt"]), do: ["slt $1, #{r0}, #{r1}", "bne $1, $0, #{label}"]
  defp resolve_pseudo([r0, im1, "li"]) do
    <<l::16,h::16>> = <<integer(im1)::32>>
    ["lui $at, #{h}", "ori #{r0}, $at, #{l}"]
  end
  defp resolve_pseudo([a0, a1, a2, cmd]), do: ["#{cmd} #{a0}, #{a1}, #{a2}"]
  defp resolve_pseudo([a0, a1, cmd]), do: ["#{cmd} #{a0}, #{a1}"]
  defp resolve_pseudo([a0, cmd]), do: ["#{cmd} #{a0}"]
  defp resolve_pseudo([cmd]), do: ["#{cmd}"]



  def resolve_early(op) do
    try do
      resolve_data(op)
    catch
      _,_ -> Regex.run(~r/(?<op>([^\s]+))(\s((?<a0>([^,]+))(,\s(?<a1>([^,]+))(,\s(?<a2>([^,]+)))?)?)?)?/, op, capture: :all_names) |> resolve_pseudo()
    end
  end

  def pow_2(0), do: 1
  def pow_2(x), do: 2 * pow_2(x - 1)
end
