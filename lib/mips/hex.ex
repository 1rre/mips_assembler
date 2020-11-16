defmodule Mips.Hex do
  @spec hex(line::bitstring()) :: nonempty_list(<<_::32>>)
  @doc """
  Take a mips instruction (or pseudoinstruction) in bitstring form and convert it into a list of 32 bit bitstrings.
  """

  # $r, $r, im::6
  def hex(<<"sll    ",d::5,t::5,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,0::6>>]
  def hex(<<"sla    ",d::5,t::5,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,1::6>>] # Might not exist
  def hex(<<"srl    ",d::5,t::5,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,2::6>>]
  def hex(<<"sra    ",d::5,t::5,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,3::6>>]
  # $r, $r, $r
  def hex(<<"sllv   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5, 4::11>>]
  def hex(<<"slav   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5, 5::11>>]
  def hex(<<"srlv   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5, 6::11>>]
  def hex(<<"srav   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5, 7::11>>]
  def hex(<<"add    ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,32::11>>]
  def hex(<<"addu   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,33::11>>]
  def hex(<<"sub    ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,34::11>>]
  def hex(<<"subu   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,35::11>>]
  def hex(<<"and    ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,36::11>>]
  def hex(<<"or     ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,37::11>>]
  def hex(<<"xor    ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,38::11>>]
  def hex(<<"nor    ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,39::11>>] # Might not exist
  def hex(<<"slt    ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,42::11>>]
  def hex(<<"sltv   ",d::5,s::5,t::5>>), do: [<<0::6,s::5,t::5,d::5,43::11>>]
  # $r, $r
  def hex(<<"jalr   ",d::5,s::5>>), do: [<<0::6,s::5,d::10,9::11>>]
  def hex(<<"mult   ",s::5,t::5>>), do: [<<0::6,s::5,t::5,24::16>>]
  def hex(<<"multu  ",s::5,t::5>>), do: [<<0::6,s::5,t::5,25::16>>]
  def hex(<<"div    ",s::5,t::5>>), do: [<<0::6,s::5,t::5,26::16>>]
  def hex(<<"divu   ",s::5,t::5>>), do: [<<0::6,s::5,t::5,27::16>>]
  # $r
  def hex(<<"jr     ",s::5>>), do: [<<0::6, s::5, 8::21>>]
  def hex(<<"mfhi   ",d::5>>), do: [<<0::16,d::5,16::11>>]
  def hex(<<"mthi   ",s::5>>), do: [<<0::6, s::5,17::21>>]
  def hex(<<"mflo   ",d::5>>), do: [<<0::16,d::5,18::11>>]
  def hex(<<"mtlo   ",s::5>>), do: [<<0::6 ,s::5,19::21>>]
  #
  def hex(<<"syscall">>), do: [<<12::32>>]
  def hex(_), do: throw("")
end
