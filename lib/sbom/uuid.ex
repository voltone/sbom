defmodule SBoM.UUID do
  def generate do
    "urn:uuid:" <> uuid()
  end

  defp uuid do
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
