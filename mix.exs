defmodule EpiLocator.MixProject do
  use Mix.Project

  def project do
    [
      app: :epi_locator,
      version: "0.1.0",
      dialyzer: dialyzer(),
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      releases: [
        epi_locator: [
          include_executables_for: [:unix],
          applications: [
            runtime_tools: :permanent
          ]
        ]
      ],
      xref: [exclude: IEx],
      test_coverage: [
        summary: [threshold: 0]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {EpiLocator.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cachex, "~> 3.3"},
      {:commcare_api, "~> 0.2"},
      {:dart_sass, "~> 0.3", runtime: Mix.env() == :dev},
      {:ecto, "~> 3.4"},
      {:ecto_sql, "~> 3.4"},
      {:elixir_xml_to_map, "~> 2.0"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:euclid, "~> 0.2"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_cloudwatch, "~> 2.0"},
      {:ex_doc, "~> 0.21", runtime: false},
      {:floki, ">= 0.0.0"},
      {:fun_with_flags, "~> 1.5"},
      {:fun_with_flags_ui, "~> 0.7"},
      {:gettext, "~> 0.11"},
      {:hackney, "~> 1.8"},
      {:hammox, "~> 0.2"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:phoenix, "~> 1.6"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix_live_view, "~> 0.17"},
      {:plug_cowboy, "~> 2.3"},
      {:postgrex, "~> 0.15"},
      {:sentry, "~> 8.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 1.0"},
      {:timex, "~> 3.5"},
      {:csv, "~> 2.4"},
      # --------------
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      # --------------
      {:wallaby, "~> 0.28", runtime: false, only: :test},
      # --------------
      {:mix_audit, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.8", only: :dev},
      {:nimble_totp, "~> 0.1.0"},
      {:bcrypt_elixir, "~> 2.0"},
      {:stream_data, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      api_reference: false,
      main: "epi-locator",
      assets: "guides/assets",
      extra_section: "GUIDES",
      extras: extras(),
      formatters: ["html"],
      source_url: "https://github.com/RatioPBC/epi-locator",
      nest_modules_by_prefix: [],
      before_closing_body_tag: &before_closing_body_tag/1,
      before_closing_head_tag: &before_closing_head_tag/1,
      output: "docs"
    ]
  end

  defp before_closing_body_tag(:html) do
    """
    <script src="https://cdn.jsdelivr.net/npm/mermaid@8.13.6/dist/mermaid.min.js"></script>
    <script>
      document.addEventListener("DOMContentLoaded", function () {
        mermaid.initialize({ startOnLoad: false, theme: "default" });
        let id = 0;
        for (const codeEl of document.querySelectorAll("pre code.mermaid")) {
          const preEl = codeEl.parentElement;
          const graphDefinition = codeEl.textContent;
          const graphEl = document.createElement("div");
          graphEl.classList.add("mermaid-container");
          const graphId = "mermaid-graph-" + id++;
          mermaid.render(graphId, graphDefinition, function (svgSource, bindListeners) {
            graphEl.innerHTML = svgSource;
            bindListeners && bindListeners(graphEl);
            preEl.insertAdjacentElement("afterend", graphEl);
            preEl.remove();
          });
        }
      });
    </script>
    """
  end

  defp before_closing_body_tag(_), do: ""

  defp before_closing_head_tag(:html) do
    """
    <style>
      #content.content-inner {
        max-width: 1282px;
      }
    </style>
    """
  end

  defp before_closing_head_tag(_), do: ""

  defp extras do
    ["README.md": [filename: "epi-locator", title: "Epi Locator"], "guides/overview.md": [title: "Overview"], LICENSE: []]
  end

  defp dialyzer do
    [
      plt_add_apps: [:iex],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      docs: ["docs", &copy_images/1],
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "sass default --no-source-map --style=compressed", "phx.digest"]
    ]
  end

  defp copy_images(_) do
    File.cp_r("guides/assets", "docs/assets")
  end
end
