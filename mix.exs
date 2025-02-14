defmodule Corn.MixProject do
  use Mix.Project

  @github_url "https://github.com/j1fig/corn"

  def project do
    [
      app: :corn,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Corn",
      source_url: @github_url,
      description: description(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "A simple, naive, but understood scheduler."
  end

  defp deps do
    [
      {:ex_doc, "~> 0.36.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
