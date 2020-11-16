defmodule Mix.Tasks.Sbom.Cyclonedx do
  @shortdoc "Generates CycloneDX SBoM"

  use Mix.Task
  import Mix.Generator

  @default_path "bom.xml"

  @moduledoc """
  Generates a Software Bill-of-Materials (SBoM) in CycloneDX format.

  ## Options

    * `--output` (`-o`): the full path to the SBoM output file (default:
      #{@default_path})
    * `--force` (`-f`): overwrite existing files without prompting for
      confirmation
    * `--dev` (`-d`): include dependencies for non-production environments
      (including `dev`, `test` or `docs`); by default only dependencies for
      MIX_ENV=prod are returned
    * `--recurse` (`-r`): in an umbrella project, generate individual output
      files for each application, rather than a single file for the entire
      project
    * `--schema` (`-s`): schema version to be used, defaults to "1.2".

  """

  @doc false
  @impl Mix.Task
  def run(all_args) do
    {opts, _args} =
      OptionParser.parse!(
        all_args,
        aliases: [o: :output, f: :force, d: :dev, r: :recurse, s: :schema],
        strict: [
          output: :string,
          force: :boolean,
          dev: :boolean,
          recurse: :boolean,
          schema: :string
        ]
      )

    output_path = opts[:output] || @default_path
    valiate_schema(opts)

    environment = (!opts[:dev] && :prod) || nil

    apps = Mix.Project.apps_paths()

    if opts[:recurse] && apps do
      Enum.each(apps, &generate_bom(&1, output_path, environment, opts[:force]))
    else
      generate_bom(output_path, environment, opts)
    end
  end

  defp generate_bom(output_path, environment, opts) do
    case SBoM.components_for_project(environment) do
      {:ok, components} ->
        xml = SBoM.CycloneDX.bom(components, opts)
        create_file(output_path, xml, force: opts[:force])

      {:error, :unresolved_dependency} ->
        dependency_error()
    end
  end

  defp generate_bom({app, path}, output_path, environment, force) do
    Mix.Project.in_project(app, path, fn _module ->
      generate_bom(output_path, environment, force)
    end)
  end

  defp dependency_error do
    shell = Mix.shell()
    shell.error("Unchecked dependencies; please run `mix deps.get`")
    Mix.raise("Can't continue due to errors on dependencies")
  end

  defp valiate_schema(opts) do
    schema_versions = ["1.2", "1.1"]

    if opts[:schema] && opts[:schema] not in schema_versions do
      shell = Mix.shell()

      shell.error(
        "invalid cyclonedx schema version, available versions are #{
          schema_versions |> Enum.join(", ")
        }"
      )

      Mix.raise("Give correct cyclonedx schema version to continue.")
    end
  end
end
