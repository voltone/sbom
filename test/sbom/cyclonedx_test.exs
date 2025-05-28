defmodule SBoM.CycloneDXTest do
  use ExUnit.Case
  import SBoM.CycloneDX

  doctest SBoM.CycloneDX

  @opts [
    schema: "1.6",
    format: "xml"
  ]

  @sample_component %{
    type: "library",
    name: "name",
    version: "0.0.1",
    purl: "pkg:hex/name@0.0.1",
    licenses: ["Apache-2.0"]
  }

  describe "bom" do
    test "serial number UUID generation" do
      assert [@sample_component] |> bom(@opts) |> to_string() =~
               ~r(serialNumber="urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
    end

    test "component without license" do
      xml =
        [
          Map.put(@sample_component, :licenses, [])
        ]
        |> bom(@opts)
        |> to_string()

      assert xml =~ ~s(<component type="library">)
      assert xml =~ ~s(<name>name</name>)
      assert xml =~ ~s(<version>0.0.1</version>)
      assert xml =~ ~s(<purl>pkg:hex/name@0.0.1</purl>)
      refute xml =~ ~s(<licenses>)
    end

    test "component with SPDX license" do
      xml =
        [
          @sample_component
        ]
        |> bom(@opts)
        |> to_string()

      assert xml =~ ~s(<licenses><license><id>Apache-2.0</id></license></licenses>)
    end

    test "component with other license" do
      xml =
        [
          Map.put(@sample_component, :licenses, ["Some other license"])
        ]
        |> bom(@opts)
        |> to_string()

      assert xml =~ ~s(<licenses><license><name>Some other license</name></license></licenses>)
    end

    test "component with hash" do
      xml =
        [
          Map.put(@sample_component, :hashes, %{
            "SHA-256" => "fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe"
          })
        ]
        |> bom(@opts)
        |> to_string()

      assert xml =~
               ~s(<hashes><hash alg="SHA-256">fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe</hash></hashes>)
    end
  end
end
