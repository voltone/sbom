defmodule SBoM do
  alias SBoM.Purl

  @doc """
  Builds a SBoM for the current Mix project. The result can be exported to
  CycloneDX XML format using the `SBoM.CycloneDX` module. Pass an environment
  of `nil` to include dependencies across all environments.
  """
  def components_for_project(environment \\ :prod) do
    Mix.Project.get!()

    {deps, not_ok} =
      Mix.Dep.load_on_environment(env: environment)
      |> Enum.split_with(&ok?/1)

    case not_ok do
      [] ->
        components =
          deps
          |> Enum.map(&component_from_dep/1)
          |> Enum.reject(&is_nil/1)

        {:ok, components}

      _ ->
        {:error, :unresolved_dependency}
    end
  end

  defp ok?(dep) do
    Mix.Dep.ok?(dep) || Mix.Dep.compilable?(dep)
  end

  defp component_from_dep(%{opts: opts} = dep) do
    case Map.new(opts) do
      %{optional: true} ->
        # If the dependency is optional at the top level, then we don't include
        # it in the SBoM
        nil

      opts_map ->
        component_from_dep(dep, opts_map)
    end
  end

  defp component_from_dep(%{scm: Hex.SCM}, opts) do
    case opts do
      %{hex: name, lock: lock, dest: dest} ->
        version = elem(lock, 2)
        sha256 = elem(lock, 3)

        hex_metadata_path = Path.expand("hex_metadata.config", dest)

        metadata =
          case :file.consult(hex_metadata_path) do
            {:ok, metadata} -> metadata
            _ -> []
          end

        {_, licenses} = metadata |> List.keyfind("licenses", 0, {"licenses", []})

        %{
          type: "library",
          name: name,
          version: version,
          purl: Purl.hex(name, version, opts[:repo]),
          hashes: %{
            "SHA-256" => sha256
          },
          licenses: licenses
        }
    end
  end

  defp component_from_dep(%{scm: Mix.SCM.Git, app: app}, opts) do
    case opts do
      %{git: git, lock: lock} ->
        version =
          case opts[:tag] do
            nil ->
              elem(lock, 2)

            tag ->
              tag
          end

        %{
          type: "library",
          name: to_string(app),
          version: version,
          purl: Purl.git(to_string(app), git, version),
          licenses: []
        }
    end
  end

  defp component_from_dep(_dep, _opts), do: nil
end
