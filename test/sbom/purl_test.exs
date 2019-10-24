defmodule SBoM.PurlTest do
  use ExUnit.Case
  import SBoM.Purl

  doctest SBoM.Purl

  setup_all do
    repos =
      Hex.State.fetch!(:repos)
      |> Map.put("myrepo", %{url: "https://myrepo.example.com"})

    Hex.State.put(:repos, repos)
  end

  test :hex do
    assert "pkg:hex/jason@1.1.2" = hex("jason", "1.1.2")
    assert "pkg:hex/jason@1.1.2" = hex("jason", "1.1.2", "hexpm")
    assert "pkg:hex/acme/foo@2.3.4" = hex("foo", "2.3.4", "hexpm:acme")

    assert "pkg:hex/jason@1.1.2" = hex("Jason", "1.1.2")
    assert "pkg:hex/jason@1.1.2" = hex("jason", "1.1.2", "HEXPM")
    assert "pkg:hex/acme/foo@2.3.4" = hex("foo", "2.3.4", "hexpm:Acme")

    assert "pkg:hex/jason@1.1.2%25" = hex("jason", "1.1.2%")
    # Not a valid organization name for Hex, but that's not what we're
    # testing here
    assert "pkg:hex/acme%25/foo@2.3.4" = hex("foo", "2.3.4", "hexpm:acme%")

    assert "pkg:hex/bar@1.2.3?repository_url=https%3A%2F%2Fmyrepo.example.com" =
             hex("bar", "1.2.3", "myrepo")
  end

  test :git do
    assert "pkg:github/package-url/purl-spec@244fd47e07d1004" =
             git("package-url", "https://github.com/package-url/purl-spec.git", "244fd47e07d1004")

    assert "pkg:github/package-url/purl-spec@244fd47e07d1004" =
             git("package-url", "git@github.com:package-url/purl-spec.git", "244fd47e07d1004")

    assert "pkg:bitbucket/birkenfeld/pygments-main@244fd47e07d1014f0aed9c" =
             git(
               "pygments-main",
               "https://bitbucket.org/birkenfeld/pygments-main.git",
               "244fd47e07d1014f0aed9c"
             )

    assert "pkg:bitbucket/birkenfeld/pygments-main@244fd47e07d1014f0aed9c" =
             git(
               "pygments-main",
               "git@bitbucket.org:birkenfeld/pygments-main.git",
               "244fd47e07d1014f0aed9c"
             )

    assert is_nil(git("ignored", "git@internal.host:some/project", "deadbeef"))
  end

  test :github do
    assert "pkg:github/package-url/purl-spec@244fd47e07d1004" =
             github("package-url/purl-spec", "244fd47e07d1004")
  end

  test :bitbucket do
    assert "pkg:bitbucket/birkenfeld/pygments-main@244fd47e07d1014f0aed9c" =
             bitbucket("birkenfeld/pygments-main", "244fd47e07d1014f0aed9c")
  end
end
