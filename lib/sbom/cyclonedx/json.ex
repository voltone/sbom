defmodule SBoM.CycloneDX.JSON do
  alias SBoM.UUID
  alias SBoM.JsonEncoder

  def bom(components, opts) do
    components
    |> base(opts)
    |> Map.merge(metadata(opts[:schema]))
    |> JsonEncoder.encode()
  end

  defp base(components, opts) do
    %{
      bomFormat: "CycloneDX",
      specVersion: opts[:schema],
      serialNumber: opts[:serial] || UUID.generate(),
      components: components,
      version: 1
    }
  end

  defp metadata("1.2") do
    %{
      timestamp: DateTime.to_iso8601(DateTime.utc_now()),
      tools: %{name: "SBoM Mix task for Elixir"}
    }
  end

  defp metadata(_), do: %{}
end
