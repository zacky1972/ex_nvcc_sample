defmodule ExNvccSample.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/zacky1972/ex_nvcc_sample"

  def project do
    [
      app: :ex_nvcc_sample,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExNvccSample",
      source_url: @source_url,
      docs: [
        main: "ExNvccSample",
        extras: ["README.md"]
      ],
      compilers: [:elixir_make] ++ Mix.compilers(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:nx, "~> 0.3"}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "Makefile",
        "c_src/*.c",
        "c_src/*.h",
        "c_src/*.cu"
      ]
    ]
  end
end
