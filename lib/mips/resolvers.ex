defmodule Mips.Resolvers do
  import Mips.Pattern
  @spec resolve_data(data::bitstring()) :: bitstring()

  # Null terminated string #
  def resolve_data(<<".asciiz ", rest::binary>>) do
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
  def resolve_data(<<".ascii ", rest::binary>>) do
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
  def resolve_data(<<".byte ", rest::binary()>>) do
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
  def resolve_data(<<".half ", rest::binary()>>) do
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
  def resolve_data(<<".word ", rest::binary()>>) do
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
  def resolve_data(<<".space ", rest::binary>>) do
    size = try do
      integer(rest)
      |> pow_2()
    catch
        _,_ -> throw "Invalid integer literal: #{rest}"
    end
    <<0::size(size)>>
  end

  # Align (resolved later) "
  def resolve_data(<<".align ", rest::binary>>) do
    size = try do
      integer(rest)
      |> pow_2()
    catch
        _,_ -> throw "Invalid integer literal: #{rest}"
    end
    %{align: size}
  end

  def resolve_op(<<".globl ", _::bits>>), do: {nil, <<>>}  # Global directives aren't needed for us?
  def resolve_op(<<".global ", _::bits>>), do: {nil, <<>>}
  def resolve_op(instr) do
    case String.split(instr, ": ") do
      [label, op] -> :ok
      [op] -> :ok
    end
  end

  def pow_2(0), do: 1
  def pow_2(x), do: 2 * pow_2(x - 1)
end
