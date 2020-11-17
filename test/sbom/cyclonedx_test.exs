defmodule SBoM.CycloneDXTest do
  use ExUnit.Case
  import SBoM.CycloneDX

  doctest SBoM.CycloneDX

  describe "bom" do
    test "serial number UUID generation." do
      assert [] |> bom() |> to_string() =~
               ~r(serialNumber="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
    end

    test "component without license" do
      xml =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: []
          }
        ]
        |> bom()
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
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: ["Apache-2.0"]
          }
        ]
        |> bom()
        |> to_string()

      assert xml =~ ~s(<licenses><license><id>Apache-2.0</id></license></licenses>)
    end

    test "component with other license" do
      xml =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: ["Some other license"]
          }
        ]
        |> bom()
        |> to_string()

      assert xml =~ ~s(<licenses><license><name>Some other license</name></license></licenses>)
    end

    test "component with hash" do
      xml =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: [],
            hashes: %{
              "SHA-256" => "fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe"
            }
          }
        ]
        |> bom()
        |> to_string()

      assert xml =~
               ~s(<hashes><hash alg="SHA-256">fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe</hash></hashes>)
    end

    test "generates CycloneDX in json format if specified" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            description: "support for CycloneDX in json support",
            purl: "pkg:hex/name@0.0.1",
            licenses: ["Apache-2.0"]
          }
        ]
        |> bom(format: :json)
        |> to_string()

      assert json =~ "{\n  \"bomFormat\": \"CycloneDX\""
    end

    test "generates CycloneDX in xml format without specified format" do
      xml =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: ["Apache-2.0"]
          }
        ]
        |> bom()
        |> to_string()

      assert xml =~ ~s(<?xml version=\"1.0\"?>)
    end
  end

  describe "json" do
    test "component without license" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            description: "support for CycloneDX in json support",
            purl: "pkg:hex/name@0.0.1",
            licenses: []
          }
        ]
        |> bom(format: :json)
        |> to_string()

      assert json =~ "\"licenses\": []"
    end

    test "component with SPDX license" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            description: "support for CycloneDX in json support",
            purl: "pkg:hex/name@0.0.1",
            licenses: ["Apache-2.0"]
          }
        ]
        |> bom(format: :json)
        |> to_string()

      assert json =~ "\"license\": {\n            \"id\": \"Apache-2.0\"\n"
    end

    test "components with other license" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            description: "support for CycloneDX in json support",
            purl: "pkg:hex/name@0.0.1",
            licenses: ["some other name"]
          }
        ]
        |> bom(format: :json)
        |> to_string()

      assert json =~ "\"license\": {\n            \"name\": \"some other name\"\n"
    end
  end
end
