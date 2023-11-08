defmodule SBoM.CycloneDXTest do
  use ExUnit.Case
  alias SBoM.CycloneDX

  describe "bom" do
    test "with json encoding" do
      assert <<"{\"version\":1,\"components\":[]" <> _>> = CycloneDX.bom([], encoding: "json")
    end

    test "with default encoding" do
      assert <<"<?xml version=\"1.0\"?>" <> _>> = CycloneDX.bom([])
    end
  end
end
