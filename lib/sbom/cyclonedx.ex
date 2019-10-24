defmodule SBoM.CycloneDX do
  @moduledoc false

  alias SBoM.License

  def bom(components, serial \\ nil)

  def bom(components, nil) do
    bom(components, uuid())
  end

  def bom(components, serial) do
    bom =
      {:bom, [serialNumber: serial, xmlns: "http://cyclonedx.org/schema/bom/1.1"],
       [
         {:components, [], Enum.map(components, &component/1)}
       ]}

    :xmerl.export_simple([bom], :xmerl_xml)
  end

  defp component(%{hashes: %{}} = component) do
    {:component, [type: component.type],
     [
       {:name, [], [[component.name]]},
       {:version, [], [[component.version]]},
       {:purl, [], [[component.purl]]},
       {:hashes, [], Enum.map(component.hashes, &hash/1)},
       {:licenses, [], Enum.map(component.licenses, &license/1)}
     ]}
  end

  defp component(component) do
    {:component, [type: component.type],
     [
       {:name, [], [[component.name]]},
       {:version, [], [[component.version]]},
       {:purl, [], [[component.purl]]},
       {:licenses, [], Enum.map(component.licenses, &license/1)}
     ]}
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
