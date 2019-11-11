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
end
