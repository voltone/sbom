defmodule SBoM.CycloneDX.Xml do
  @moduledoc false
  alias SBoM.{CycloneDX, License}

  def bom(components, options) do
    bom =
      case options[:schema] do
        "1.1" ->
          {:bom,
           [
             serialNumber: options[:serial] || CycloneDX.uuid(),
             xmlns: "http://cyclonedx.org/schema/bom/1.1"
           ], [{:components, [], Enum.map(components, &component/1)}]}

        _ ->
          {:bom,
           [
             serialNumber: options[:serial] || CycloneDX.uuid(),
             xmlns: "http://cyclonedx.org/schema/bom/1.2"
           ],
           [
             {:metadata, [],
              [
                {:timestamp, [], [[DateTime.utc_now() |> DateTime.to_iso8601()]]},
                {:tools, [], [tool: [name: [["SBoM Mix task for Elixir"]]]]}
              ]},
             {:components, [], Enum.map(components, &component/1)}
           ]}
      end

    :xmerl.export_simple([bom], :xmerl_xml)
  end

  defp component(component) do
    {:component, [type: component.type], component_fields(component)}
  end

  defp component_fields(component) do
    component |> Enum.map(&component_field/1) |> Enum.reject(&is_nil/1)
  end

  @simple_fields [:name, :version, :purl, :cpe, :description]

  defp component_field({field, value}) when field in @simple_fields and not is_nil(value) do
    {field, [], [[value]]}
  end

  defp component_field({:hashes, hashes}) when is_map(hashes) do
    {:hashes, [], Enum.map(hashes, &hash/1)}
  end

  defp component_field({:licenses, [_ | _] = licenses}) do
    {:licenses, [], Enum.map(licenses, &license/1)}
  end

  defp component_field(_other), do: nil

  defp hash({algorithm, hash}) do
    {:hash, [alg: algorithm], [[hash]]}
  end

  defp license(name) do
    # If the name is a recognized SPDX license ID, or if we can turn it into
    # one, we return a bom:license with a bom:id element
    case License.spdx_id(name) do
      nil ->
        {:license, [],
         [
           {:name, [], [[name]]}
         ]}

      id ->
        {:license, [],
         [
           {:id, [], [[id]]}
         ]}
    end
  end
end
