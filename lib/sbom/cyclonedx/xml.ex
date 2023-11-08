defmodule SBoM.CycloneDX.XML do
  alias SBoM.UUID

  @simple_fields [:name, :version, :purl, :cpe, :description]

  def bom(components, opts) do
    bom = [
      {:bom, header(opts[:schema], opts[:serial]), content(opts[:schema], components)}
    ]

    :xmerl.export_simple(bom, :xmerl_xml)
  end

  defp header(version, serial) do
    [
      serialNumber: serial || UUID.generate(),
      xmlns: xmlns(version)
    ]
  end

  defp xmlns("1.2"), do: "http://cyclonedx.org/schema/bom/1.2"
  defp xmlns(_), do: "http://cyclonedx.org/schema/bom/1.1"

  defp content("1.2", components) do
    [
      {:metadata, [],
       [
         {:timestamp, [], [[DateTime.utc_now() |> DateTime.to_iso8601()]]},
         {:tools, [], [tool: [name: [["SBoM Mix task for Elixir"]]]]}
       ]},
      {:components, [], Enum.map(components, &component/1)}
    ]
  end

  defp content(_, components) do
    [{:components, [], Enum.map(components, &component/1)}]
  end

  defp component(component) do
    {:component, [type: component.type], component_fields(component)}
  end

  defp component_fields(component) do
    component |> Enum.map(&component_field/1) |> Enum.reject(&is_nil/1)
  end

  defp component_field({field, value}) when field in @simple_fields and not is_nil(value) do
    {field, [], [[value]]}
  end

  defp component_field({:hashes, hashes}) when is_list(hashes) do
    {:hashes, [], Enum.map(hashes, &hash/1)}
  end

  defp component_field({:licenses, [_ | _] = licenses}) do
    {:licenses, [], Enum.map(licenses, &license/1)}
  end

  defp component_field(_other), do: nil

  defp license(%{license: %{id: id}}) do
    {:license, [], [{:id, [], [[id]]}]}
  end

  defp license(%{license: %{name: name}}) do
    {:license, [], [{:name, [], [[name]]}]}
  end

  defp hash(%{alg: algorithm, content: hash}) do
    {:hash, [alg: algorithm], [[hash]]}
  end
end
