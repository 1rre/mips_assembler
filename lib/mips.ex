defmodule Mips do
  use Application
  @spec start_link :: {:ok, pid}
  @spec start(any, any) :: {:ok, pid}
  @spec stop(any) :: :ok

  def start_link do
    Task.start_link(fn -> Mix.Tasks.Mips.run(System.argv) end)
  end

  def start(_, args) do
    Task.start(fn -> Mix.Tasks.Mips.run(args) end)
  end

  def stop(_) do
    System.halt(0)
  end
end
