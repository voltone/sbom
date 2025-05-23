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
    schema = options[:schema]

    bom =
      case schema do
        "1.1" ->
          {:bom, bom_attributes(options, schema),
           [
             components(components, schema)
           ]}

        _ ->
          {:bom, bom_attributes(options, schema),
           [
             metadata(options, schema),
             components(components, schema)
           ]}
      end

    :xmerl.export_simple([bom], :xmerl_xml)
  end

  defp bom_attributes(options, schema) do
    [
      serialNumber: options[:serial] || urn_uuid(),
      xmlns: "http://cyclonedx.org/schema/bom/#{schema}"
    ]
  end

  defp metadata(_options, _schema) do
    {:metadata, [],
     [
       {:timestamp, [], [[DateTime.utc_now() |> DateTime.to_iso8601()]]},
       {:tools, [], [tool: [name: [["SBoM Mix task for Elixir"]]]]}
     ]}
  end

  defp components(components, schema) do
    {:components, [], Enum.map(components, &component(&1, schema))}
  end

  defp component(component, schema) do
    {:component, [type: component.type], component_fields(component, schema)}
  end

  defp component_fields(component, schema) do
    [:name, :version, :description, :hashes, :licenses, :cpe, :purl]
    |> Enum.map(&component_field(&1, component[&1], schema))
    |> Enum.reject(&is_nil/1)
  end

  @simple_fields [:name, :version, :purl, :cpe, :description]

  defp component_field(field, value, _schema)
       when field in @simple_fields and not is_nil(value) do
    {field, [], [[value]]}
  end

  defp component_field(:hashes, hashes, _schema) when is_map(hashes) do
    {:hashes, [], Enum.map(hashes, &hash/1)}
  end

  defp component_field(:licenses, [_ | _] = licenses, _schema) do
    {:licenses, [], Enum.map(licenses, &license/1)}
  end

  defp component_field(_field, _value, _schema), do: nil

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

  defp urn_uuid(), do: "urn:uuid:#{uuid()}"

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
