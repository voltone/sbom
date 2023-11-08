defmodule SBoM.UUID do
  def generate do
    "urn:uuid:" <> UUID.uuid4()
  end
end
