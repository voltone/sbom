defmodule SBoM.CycloneDX.JSONTest do
  use ExUnit.Case
  alias SBoM.CycloneDX.JSON

  describe "bom/2" do
    test "serial number UUID generation" do
      assert []
             |> JSON.bom(schema: "1.2")
             |> to_string() =~
               ~r("serialNumber":"urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
    end

    test "component without license" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: []
          }
        ]
        |> JSON.bom(schema: "1.2")
        |> to_string()

      assert json =~ ~s("type":"library")
      assert json =~ ~s("name":"name")
      assert json =~ ~s("version":"0.0.1")
      assert json =~ ~s("purl":"pkg:hex/name@0.0.1")
      assert json =~ ~s("licenses":[])
    end

    test "component with SPDX license" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: [%{license: %{id: "Apache-2.0"}}]
          }
        ]
        |> JSON.bom(schema: "1.2")
        |> to_string()

      assert json =~ ~s("licenses":[{"license":{"id":"Apache-2.0"}}])
    end

    test "component with other license" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: [%{license: %{name: "Some other license"}}]
          }
        ]
        |> JSON.bom(schema: "1.2")
        |> to_string()

      assert json =~ ~s("licenses":[{"license":{"name":"Some other license"}}])
    end

    test "component with hash" do
      json =
        [
          %{
            type: "library",
            name: "name",
            version: "0.0.1",
            purl: "pkg:hex/name@0.0.1",
            licenses: [],
            hashes: [
              %{
                alg: "SHA-256",
                content: "fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe"
              }
            ]
          }
        ]
        |> JSON.bom(schema: "1.2")
        |> to_string()

      assert json =~
               ~s("hashes":[{"alg":"SHA-256","content":"fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe"}]}])
    end
  end
end
