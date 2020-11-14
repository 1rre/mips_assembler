defmodule Mips.Const do
  @spec resolve_reg(reg_name::integer()) :: <<_::16>>
  @spec registers() :: [<<_::16>>, ...]

  defmacro registers do
    quote do [
      "0", "1", "2", "3", "4", "5", "6", "7",
      "8", "9", "10", "11", "12", "13", "14", "15",
      "16", "17", "18", "19", "20", "21", "22", "23",
      "24", "25", "26", "27", "28", "29", "30", "31",
      "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3",
      "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
      "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
      "t8", "t9", "k0", "k1", "gp", "sp", "s8", "ra"
    ] end
  end

  def resolve_reg(24948), do: <<?$,1::8>>
  def resolve_reg(30256), do: <<?$,2::8>>
  def resolve_reg(30257), do: <<?$,3::8>>
  def resolve_reg(24880), do: <<?$,4::8>>
  def resolve_reg(24881), do: <<?$,5::8>>
  def resolve_reg(24882), do: <<?$,6::8>>
  def resolve_reg(24883), do: <<?$,7::8>>
  def resolve_reg(29744), do: <<?$,8::8>>
  def resolve_reg(29745), do: <<?$,9::8>>
  def resolve_reg(29746), do: <<?$,10::8>>
  def resolve_reg(29747), do: <<?$,11::8>>
  def resolve_reg(29748), do: <<?$,12::8>>
  def resolve_reg(29749), do: <<?$,13::8>>
  def resolve_reg(29750), do: <<?$,14::8>>
  def resolve_reg(29751), do: <<?$,15::8>>
  def resolve_reg(29488), do: <<?$,16::8>>
  def resolve_reg(29489), do: <<?$,17::8>>
  def resolve_reg(29490), do: <<?$,18::8>>
  def resolve_reg(29491), do: <<?$,19::8>>
  def resolve_reg(29492), do: <<?$,20::8>>
  def resolve_reg(29493), do: <<?$,21::8>>
  def resolve_reg(29494), do: <<?$,22::8>>
  def resolve_reg(29495), do: <<?$,23::8>>
  def resolve_reg(29752), do: <<?$,24::8>>
  def resolve_reg(29753), do: <<?$,25::8>>
  def resolve_reg(27440), do: <<?$,26::8>>
  def resolve_reg(27441), do: <<?$,27::8>>
  def resolve_reg(26480), do: <<?$,28::8>>
  def resolve_reg(29496), do: <<?$,29::8>>
  def resolve_reg(29552), do: <<?$,30::8>>
  def resolve_reg(29281), do: <<?$,31::8>>
end
