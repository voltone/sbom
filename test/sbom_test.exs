defmodule SBoMTest do
  use ExUnit.Case
  doctest SBoM

  setup_all do
    Mix.shell(Mix.Shell.Process)
    :ok
  end

  setup do
    Mix.Shell.Process.flush()
    :ok
  end

  describe "components_for_project" do
    test "basic project" do
      Mix.Project.in_project(:sample1, "test/fixtures/sample1", fn _mod ->
        Mix.Task.run("deps.clean", ["--all"])
        assert {:error, :unresolved_dependency} = SBoM.components_for_project()

        Mix.Task.run("deps.get")
        assert {:ok, list} = SBoM.components_for_project()
        assert length(list) == 8
        assert Enum.find(list, &match?(%{name: "hackney"}, &1))
        refute Enum.find(list, &match?(%{name: "ex_doc"}, &1))
        refute Enum.find(list, &match?(%{name: "meck"}, &1))
        refute Enum.find(list, &match?(%{name: "jason"}, &1))

        assert {:ok, list} = SBoM.components_for_project(nil)
        assert length(list) == 14
        assert Enum.find(list, &match?(%{name: "hackney"}, &1))
        assert Enum.find(list, &match?(%{name: "ex_doc"}, &1))
        assert Enum.find(list, &match?(%{name: "meck"}, &1))
        refute Enum.find(list, &match?(%{name: "jason"}, &1))
      end)
    end

    test "project with path dependency" do
      Mix.Project.in_project(:with_path_dep, "test/fixtures/with_path_dep", fn _mod ->
        Mix.Task.run("deps.clean", ["--all"])
        assert {:error, :unresolved_dependency} = SBoM.components_for_project()

        Mix.Task.run("deps.get")
        assert {:ok, list} = SBoM.components_for_project()
        assert length(list) == 9
        assert Enum.find(list, &match?(%{name: "hackney"}, &1))
        refute Enum.find(list, &match?(%{name: "ex_doc"}, &1))
        refute Enum.find(list, &match?(%{name: "meck"}, &1))
        assert Enum.find(list, &match?(%{name: "jason"}, &1))

        assert {:ok, list} = SBoM.components_for_project(nil)
        assert length(list) == 9
        assert Enum.find(list, &match?(%{name: "hackney"}, &1))
        refute Enum.find(list, &match?(%{name: "ex_doc"}, &1))
        refute Enum.find(list, &match?(%{name: "meck"}, &1))
        assert Enum.find(list, &match?(%{name: "jason"}, &1))
      end)
    end
  end
end
