defmodule SBoM.CycloneDX do
  @moduledoc """
  Generate a CycloneDX SBoM in XML format.
  """

  alias __MODULE__.XML
  alias __MODULE__.JSON

  @doc """
  Generate a CycloneDX SBoM in XML format from the specified list of
  components. Returns an `iolist`, which may be written to a file or IO device,
  or converted to a String using `IO.iodata_to_binary/1`

  If no serial number is specified a random UUID is generated.
  """

  def bom(components, opts \\ []) do
    case opts[:encoding] || "xml" do
      "xml" -> XML.bom(components, opts)
      "json" -> JSON.bom(components, opts)
    end
  end
end
