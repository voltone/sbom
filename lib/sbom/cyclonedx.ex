defmodule SBoM.CycloneDX do
  @moduledoc """
  Generate a CycloneDX SBoM in XML format.
  """

  alias SBoM.License

  @doc """
  Generate a CycloneDX SBoM in XML or JSON format from the specified list of
  components. Returns an `iolist`, which may be written to a file or IO device,
  or converted to a String using `IO.iodata_to_binary/1`

  The first component in the list is assumed to be the top-level component
  that the SBoM describes.

  If no serial number is specified a random UUID is generated.
  """
  def bom(components, options \\ []) do
    case {options[:format], options[:schema]} do
      {"xml", schema} ->
        doc = xml_bom(components, schema, options)
        :xmerl.export_simple([doc], :xmerl_xml)

      {"json", "1.1"} ->
        raise "Invalid schema version: CycloneDX 1.1 does not support JSON format"

      {"json", schema} ->
        case Code.ensure_loaded(:json) do
          {:error, :nofile} ->
            raise "JSON output requires OTP >=27"

          {:module, :json} ->
            doc = json_bom(components, schema, options)
            :json.encode(doc)
        end
    end
  end

  defp xml_bom([_top_level_component | components], "1.1" = schema, options) do
    {:bom, xml_bom_attributes(options, schema),
     [
       xml_components(components, schema)
     ]}
  end

  defp xml_bom([top_level_component | components], schema, options) do
    {:bom, xml_bom_attributes(options, schema),
     [
       xml_metadata(top_level_component, options, schema),
       xml_components(components, schema)
     ]}
  end

  defp xml_bom_attributes(options, schema) do
    [
      serialNumber: options[:serial] || urn_uuid(),
      xmlns: "http://cyclonedx.org/schema/bom/#{schema}"
    ]
  end

  defp xml_metadata(component, _options, schema) do
    {:metadata, [],
     [
       {:timestamp, [], [[DateTime.utc_now() |> DateTime.to_iso8601()]]},
       {:tools, [],
        [
          {:tool, [],
           [
             name: [["SBoM Mix task for Elixir"]],
             version: [[SBoM.tool_version()]]
           ]}
        ]},
       xml_component(component, schema)
     ]}
  end

  defp xml_components(components, schema) do
    {:components, [], Enum.map(components, &xml_component(&1, schema))}
  end

  defp xml_component(component, schema) do
    {:component, [type: component.type], xml_component_fields(component, schema)}
  end

  defp xml_component_fields(component, schema) do
    [:name, :version, :description, :hashes, :licenses, :cpe, :purl]
    |> Enum.map(&xml_component_field(&1, component[&1], schema))
    |> Enum.reject(&is_nil/1)
  end

  @simple_fields [:name, :version, :purl, :cpe, :description]

  defp xml_component_field(field, value, _schema)
       when field in @simple_fields and not is_nil(value) do
    {field, [], [[value]]}
  end

  defp xml_component_field(:hashes, hashes, _schema) when is_map(hashes) do
    {:hashes, [], Enum.map(hashes, &xml_hash/1)}
  end

  defp xml_component_field(:licenses, [_ | _] = licenses, _schema) do
    {:licenses, [], Enum.map(licenses, &xml_license/1)}
  end

  defp xml_component_field(_field, _value, _schema), do: nil

  defp xml_license(name) do
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

  defp xml_hash({algorithm, hash}) do
    {:hash, [alg: algorithm], [[hash]]}
  end

  defp json_bom([top_level_component | components], schema, options) do
    %{
      bomFormat: "CycloneDX",
      specVersion: schema,
      serialNumber: options[:serial] || urn_uuid(),
      version: options[:version] || 1,
      metadata: json_metadata(top_level_component, schema, options),
      components: Enum.map(components, &json_component(&1, schema, options))
    }
  end

  defp json_metadata(top_level_component, schema, options) do
    %{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      tools: [
        %{
          name: "SBoM Mix task for Elixir",
          version: SBoM.tool_version()
        }
      ],
      component: json_component(top_level_component, schema, options)
    }
  end

  defp json_component(component, schema, options) do
    [
      type: component[:type],
      name: component[:name],
      version: component[:version],
      description: component[:description],
      hashes: json_hashes(component[:hashes], schema, options),
      licenses: json_licenses(component[:licenses], schema, options),
      purl: component[:purl],
      cpe: component[:cpe]
    ]
    |> Enum.reject(&is_nil(elem(&1, 1)))
    |> Enum.into(%{})
  end

  defp json_hashes(nil, _schema, _options), do: nil

  defp json_hashes(hashes, _schema, _options) when is_map(hashes) do
    Enum.map(hashes, fn {alg, content} ->
      %{
        alg: alg,
        content: content
      }
    end)
  end

  defp json_licenses(nil, _schema, _options), do: nil

  defp json_licenses(licenses, _schema, _options) when is_list(licenses) do
    Enum.map(licenses, fn name ->
      license =
        case License.spdx_id(name) do
          nil ->
            %{name: name}

          id ->
            %{id: id}
        end

      %{
        license: license
      }
    end)
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
