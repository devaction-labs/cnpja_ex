defmodule Cnpja.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/devaction-labs/cnpja_ex"

  def project do
    [
      app: :cnpja_ex,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      description:
        "Elixir SDK for the CNPJá API — CNPJ, CEP, RFB, Simples Nacional, CCC and SUFRAMA lookups.",
      package: package(),
      name: "Cnpja",
      source_url: @source_url,
      homepage_url: "https://cnpja.com",
      docs: docs(),
      dialyzer: [plt_add_apps: [:mix]],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.github": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "API Reference" => "https://cnpja.com/api/reference"
      },
      maintainers: ["Alex Nogueira"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Responses: [
          Cnpja.Credit,
          Cnpja.Zip,
          Cnpja.Company,
          Cnpja.Office,
          Cnpja.OfficeSearch,
          Cnpja.Person,
          Cnpja.PersonSearch,
          Cnpja.Rfb,
          Cnpja.Simples,
          Cnpja.Ccc,
          Cnpja.Suframa
        ],
        Shared: [
          Cnpja.Label,
          Cnpja.Address,
          Cnpja.Activity,
          Cnpja.Phone,
          Cnpja.Email,
          Cnpja.Member,
          Cnpja.Agent,
          Cnpja.PersonRef,
          Cnpja.Country,
          Cnpja.StateRegistration,
          Cnpja.SimplesOpt,
          Cnpja.SimplesHistory,
          Cnpja.OfficeLinks,
          Cnpja.SuframaIncentive
        ],
        Internals: [Cnpja.Client, Cnpja.Config, Cnpja.Error]
      ]
    ]
  end
end
