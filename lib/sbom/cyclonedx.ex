defmodule SBoM.CycloneDX do
  @moduledoc """
  Generate a CycloneDX SBoM in XML format.
  """

  alias SBoM.License

  @doc """
  Generate a CycloneDX SBoM in XML format from the specified list of
  components. Returns an `iolist`, which may be written to a file or IO device,
  or converted to a String using `IO.iodata_to_binary/1`

  If no serial number is specified a random UUID is generated.
  """

  def bom(components, options \\ []) do
    bom =
      case options[:schema] do
        "1.1" ->
          {:bom,
           [
             serialNumber: options[:serial] || uuid(),
             xmlns: "http://cyclonedx.org/schema/bom/1.1"
           ], [{:components, [], Enum.map(components, &component/1)}]}

        _ ->
          {:bom,
           [
             serialNumber: options[:serial] || uuid(),
             xmlns: "http://cyclonedx.org/schema/bom/1.2"
           ],
           [
             {:metadata, [],
              [
                {:timestamp, [], [[DateTime.utc_now() |> DateTime.to_iso8601()]]},
                {:tools, [], [tool: [vendor: [["CycloneDX"]], name: [["Elixir module"]]]]}
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

  defp hash({algorithm, hash}) do
    {:hash, [alg: algorithm], [[hash]]}
  end

  defp uuid() do
    [
      :crypto.strong_rand_bytes(4),
      :crypto.strong_rand_bytes(2),
      <<4::4, :crypto.strong_rand_bytes(2)::binary-size(12)-unit(1)>>,
      <<2::2, :crypto.strong_rand_bytes(2)::binary-size(14)-unit(1)>>,
      :crypto.strong_rand_bytes(6)
    ]
    |> Enum.map(&Base.encode16(&1, case: :lower))
    |> Enum.join("-")
  end
end
