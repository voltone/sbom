defmodule SBoM.CycloneDX do
  @moduledoc """
  Generate a CycloneDX SBoM in XML and JSON format.
  """

  alias SBoM.CycloneDX.{Json, Xml}

  @doc """
  Generate a CycloneDX SBoM in XML or in JSON format from the specified list of
  components. Returns an `iolist`, which may be written to a file or IO device,
  or converted to a String using `IO.iodata_to_binary/1`

  ### Options

  :format - specifies the format given. If format is ':json', CycloneDX SBoM in JSON format is generated  otherwise
            will be generated in XML format.

  :schema - specifies the schema version used i.e '1.1', '1.2'. CycloneDX SBoM in XML will be generated based 
            on the schema version passed. The default '1.1' schema version will be used if its not specified.

  :serial - specifies the serial number used. If no serial number is specified a random UUID is generated.
  """

  def bom(components, options \\ []) do
    case options[:format] do
      :json -> Json.bom(components, options)
      _ -> Xml.bom(components, options)
    end
  end

  def uuid() do
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
