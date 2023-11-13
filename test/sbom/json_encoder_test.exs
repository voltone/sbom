defmodule SBoM.JsonEncoderTest do
  use ExUnit.Case
  alias SBoM.JsonEncoder

  describe "encode/1" do
    test "test with all types of data" do
      assert ~s/"data"/ == JsonEncoder.encode("data")
      assert ~s/["data"]/ == JsonEncoder.encode(["data"])
      assert ~s/{"key":"value"}/ == JsonEncoder.encode(%{key: "value"})
      assert ~s/null/ == JsonEncoder.encode(nil)
      assert ~s/false/ == JsonEncoder.encode(false)
      assert ~s/true/ == JsonEncoder.encode(true)
      assert ~s/"test"/ == JsonEncoder.encode(:test)
      assert ~s/42/ == JsonEncoder.encode(42)
      assert ~s/99.99/ == JsonEncoder.encode(99.99)
      assert ~s/9.9e100/ == JsonEncoder.encode(9.9e100)
      assert ~s/"hello\\nworld"/ == JsonEncoder.encode("hello\nworld")
      assert ~s/"\\nhello\\nworld\\n"/ == JsonEncoder.encode("\nhello\nworld\n")
      assert ~s/"\\""/ == JsonEncoder.encode("\"")
      assert ~s/"\\u0000\"/ == JsonEncoder.encode("\0")
      assert ~s/{"key":[{"key":"teste"}]}/ == JsonEncoder.encode(%{key: [%{key: "teste"}]})
      assert ~s/{"key":"data"}/ == JsonEncoder.encode(key: "data")
    end
  end
end
