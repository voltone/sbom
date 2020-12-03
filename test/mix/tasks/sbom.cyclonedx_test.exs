defmodule Mix.Tasks.Sbom.CyclonedxTest do
  use ExUnit.Case

  setup_all do
    Mix.shell(Mix.Shell.Process)
    :ok
  end

  setup do
    Mix.Shell.Process.flush()
    :ok
  end

  test "mix task" do
    Mix.Project.in_project(__MODULE__, "test/fixtures/sample1", fn _mod ->
      Mix.Task.rerun("deps.clean", ["--all"])

      assert_raise Mix.Error, "Can't continue due to errors on dependencies", fn ->
        Mix.Task.rerun("sbom.cyclonedx", ["-d", "-f"])
      end

      Mix.Task.rerun("deps.get")
      Mix.Shell.Process.flush()

      Mix.Task.rerun("sbom.cyclonedx", ["-d", "-f"])
      assert_received {:mix_shell, :info, ["* creating bom.xml"]}
    end)
  end

  test "schema validation" do
    Mix.Project.in_project(__MODULE__, "test/fixtures/sample1", fn _mod ->
      Mix.Task.rerun("sbom.cyclonedx", ["-d", "-f", "-s", "1.1"])
      assert_received {:mix_shell, :info, ["* creating bom.xml"]}

      assert_raise Mix.Error, "Give correct cyclonedx schema version to continue.", fn ->
        Mix.Task.rerun("sbom.cyclonedx", ["-d", "-f", "-s", "invalid"])
      end
    end)
  end

  test "json version support  validation" do
    Mix.Project.in_project(__MODULE__, "test/fixtures/sample1", fn _mod ->
      assert_raise Mix.Error, "JSON is NOT supported for version 1.1 of cyclonedx.", fn ->
        Mix.Task.rerun("sbom.cyclonedx", ["-d", "-f", "-s", "1.1", "-o", "bom.json"])
      end
    end)
  end
end
