defmodule SBoM.LicenseTest do
  use ExUnit.Case
  import SBoM.License

  doctest SBoM.License

  test :spdx_id do
    assert "0BSD" = spdx_id("0BSD")
    assert "MIT" = spdx_id("mit")
    assert "BSD-3-Clause" = spdx_id("BSD 3-clause")
    assert "Apache-2.0" = spdx_id("APACHE-2.0")
    assert is_nil(spdx_id("Some other license"))
    # Fixups:
    assert "Apache-2.0" = spdx_id("Apache 2")
    assert "Apache-2.0" = spdx_id("Apache license 2.0")
    assert "BSD-3-Clause" = spdx_id("BSD-3")
    assert "MIT" = spdx_id("MIT license")
    assert "MPL-2.0" = spdx_id("Mozilla Public License version 2.0")
    assert "MPL-2.0" = spdx_id("Mozilla Public License,  version 2.0")
  end
end
