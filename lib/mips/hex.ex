defmodule Mips.Hex do
  @spec hex(line::bitstring()) :: nonempty_list(<<_::32>>)
  @doc """
  Take a mips instruction (or pseudoinstruction) in bitstring form and convert it into a list of 32 bit bitstrings.
  """

  # $r, $r, im::6
  def hex(<<"sll    ",d::8,t::8,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,0::6>>]
  def hex(<<"sla    ",d::8,t::8,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,1::6>>] # Might not exist
  def hex(<<"srl    ",d::8,t::8,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,2::6>>]
  def hex(<<"sra    ",d::8,t::8,_::26,h::6>>), do: [<<0::11,t::5,d::5,h::5,3::6>>]
  # $r, $r, $r
  def hex(<<"sllv   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5, 4::11>>]
  def hex(<<"slav   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5, 5::11>>]
  def hex(<<"srlv   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5, 6::11>>]
  def hex(<<"srav   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5, 7::11>>]
  def hex(<<"add    ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,32::11>>]
  def hex(<<"addu   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,33::11>>]
  def hex(<<"sub    ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,34::11>>]
  def hex(<<"subu   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,35::11>>]
  def hex(<<"and    ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,36::11>>]
  def hex(<<"or     ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,37::11>>]
  def hex(<<"xor    ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,38::11>>]
  def hex(<<"nor    ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,39::11>>] # Might not exist
  def hex(<<"slt    ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,42::11>>]
  def hex(<<"sltv   ",d::8,s::8,t::8>>), do: [<<0::6,s::5,t::5,d::5,43::11>>]
  # $r, $r
  def hex(<<"jalr   ",d::8,s::8>>), do: [<<0::6,s::5,0::5,d::5,9::11>>]
  # $r
  def hex(<<"jr     ",s::8>>), do: [<<0::6,s::5,8::21>>]
  def hex(<<"mfhi   ",d::8>>), do: [<<0::16,d::5,16::11>>]
  #
  def hex(<<"syscall">>), do: [<<12::32>>]
  def hex(_), do: throw("")
end
