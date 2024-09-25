defmodule SBoM.UUIDTest do
  use ExUnit.Case
  alias SBoM.UUID

  describe "generate" do
    test "serial number generation" do
      assert UUID.generate() =~
               ~r(urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})
    end
  end
end
