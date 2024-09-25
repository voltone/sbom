defmodule SBoM.Cpe do
  @moduledoc false

  def hex(name, version, repo \\ "hexpm") do
    do_hex(String.downcase(name), version, String.downcase(repo))
  end

  defp do_hex("hex_core", version, "hexpm") do
    "cpe:2.3:a:hex:hex_core:#{version}:*:*:*:*:*:*:*"
  end

  defp do_hex("plug", version, "hexpm") do
    "cpe:2.3:a:elixir-plug:plug:#{version}:*:*:*:*:*:*:*"
  end

  defp do_hex("phoenix", version, "hexpm") do
    "cpe:2.3:a:phoenixframework:phoenix:#{version}:*:*:*:*:*:*:*"
  end

  defp do_hex("coherence", version, "hexpm") do
    "cpe:2.3:a:coherence_project:coherence:#{version}:*:*:*:*:*:*:*"
  end

  defp do_hex("xain", version, "hexpm") do
    "cpe:2.3:a:emetrotel:xain:#{version}:*:*:*:*:*:*:*"
  end

  defp do_hex("sweet_xml", version, "hexpm") do
    "cpe:2.3:a:kbrw:sweet_xml:#{version}:*:*:*:*:*:*:*"
  end

  defp do_hex(_name, _version, _repo), do: ""
end
