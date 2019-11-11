defmodule SBoM.MixProject do
  use Mix.Project

  @version "0.6.0"

  def project do
    [
      app: :sbom,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "SBoM",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/voltone/sbom"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:hex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev}
    ]
  end

  defp description do
    "Mix task to generate a Software Bill-of-Materials (SBoM) in CycloneDX format"
  end

  defp package do
    [
      maintainers: ["Bram Verburg"],
      licenses: ["BSD-3-Clause"],
      links: %{"GitHub" => "https://github.com/voltone/sbom"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end
