defmodule SBoM.JsonEncoder do
  def encode(data) when is_map(data) do
    data
    |> Enum.map(&~s/"#{to_string(elem(&1, 0))}":#{encode(elem(&1, 1))}/)
    |> Enum.join(",")
    |> then(&~s/{#{&1}}/)
  end

  def encode(data) when is_list(data) do
    if is_tuple(List.first(data)) do
      data
      |> Map.new()
      |> encode()
    else
      data
      |> Enum.map(&encode/1)
      |> Enum.join(",")
      |> then(&~s/[#{&1}]/)
    end
  end

  def encode(nil), do: "null"
  def encode(data) when is_tuple(data), do: data |> Tuple.to_list() |> encode()
  def encode(data) when is_number(data), do: ~s/#{data}/
  def encode(data) when is_boolean(data), do: ~s/#{to_string(data)}/
  def encode(data) when is_atom(data), do: data |> to_string() |> encode()
  def encode(data) when is_binary(data), do: <<?">> <> encode_binary_recursive(data) <> <<?">>

  def encode(data) do
    ~s/#{to_string(inspect(data))}/
  end

  defp encode_binary_recursive(data, acc \\ [])

  defp encode_binary_recursive(<<head::utf8, tail::binary>>, acc) do
    encode_binary_recursive(tail, encode_binary_character(head, acc))
  end

  defp encode_binary_recursive(<<>>, acc), do: acc |> Enum.reverse() |> to_string

  defp encode_binary_character(?", acc), do: [?", ?\\ | acc]
  defp encode_binary_character(?\b, acc), do: [?b, ?\\ | acc]
  defp encode_binary_character(?\f, acc), do: [?f, ?\\ | acc]
  defp encode_binary_character(?\n, acc), do: [?n, ?\\ | acc]
  defp encode_binary_character(?\r, acc), do: [?r, ?\\ | acc]
  defp encode_binary_character(?\t, acc), do: [?t, ?\\ | acc]
  defp encode_binary_character(?\\, acc), do: [?\\, ?\\ | acc]

  defp encode_binary_character(char, acc) when is_number(char) and char < 32 do
    encode_hexadecimal_unicode_control_character(char, [?u, ?\\ | acc])
  end

  # anything else besides these control characters, just let it through
  defp encode_binary_character(char, acc) when is_number(char), do: [char | acc]

  defp encode_hexadecimal_unicode_control_character(char, acc) when is_number(char) do
    [
      char
      |> Integer.to_charlist(16)
      |> zeropad_hexadecimal_unicode_control_character
      |> Enum.reverse()
      | acc
    ]
  end

  defp zeropad_hexadecimal_unicode_control_character([a, b, c]), do: [?0, a, b, c]
  defp zeropad_hexadecimal_unicode_control_character([a, b]), do: [?0, ?0, a, b]
  defp zeropad_hexadecimal_unicode_control_character([a]), do: [?0, ?0, ?0, a]
  defp zeropad_hexadecimal_unicode_control_character(iolist) when is_list(iolist), do: iolist
end
