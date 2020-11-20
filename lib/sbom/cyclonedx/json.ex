defmodule SBoM.CycloneDX.Json do
  @moduledoc false

  alias alias SBoM.License

  def bom(components, opts) do
    %{
      bomFormat: "CycloneDX",
      specVersion: opts[:schema] || "1.2",
      serialNumber: opts[:serial] || SBoM.CycloneDX.uuid(),
      version: "1",
      metadata: metadata(),
      components: components(components)
    }
    |> Jason.encode_to_iodata!(pretty: true)
  end

  defp metadata do
    %{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      tools: [%{name: "SBoM Mix task for Elixir"}]
    }
  end

  defp components(components) do
    Enum.map(components, fn component ->
      %{
        type: component.type,
        name: component.name,
        version: component.version,
        description: component.description,
        licenses: licenses(component.licenses),
        purl: component.purl
      }
    end)
  end

  defp licenses(licenses) do
    Enum.map(licenses, fn license ->
      case License.spdx_id(license) do
        nil -> %{license: %{name: license}}
        id -> %{license: %{id: id}}
      end
    end)
  end
end
