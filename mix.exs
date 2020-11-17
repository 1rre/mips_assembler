defmodule Mips.MixProject do
  use Mix.Project

  def project do
    [
      app: :mips,
      version: "0.1.2",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      default_task: "mips",
      escript: [
        main_module: Mix.Tasks.Mips,
        comment: "Test"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    ]
  end
end
