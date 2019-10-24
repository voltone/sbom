defmodule SBoM.Purl do
  @moduledoc false

  # https://github.com/package-url/purl-spec

  def hex(name, version, repo \\ "hexpm") do
    do_hex(String.downcase(name), version, String.downcase(repo))
  end

  defp do_hex(name, version, "hexpm") do
    purl(["hex", name], version)
  end

  defp do_hex(name, version, "hexpm:" <> organization) do
    purl(["hex", organization, name], version)
  end

  defp do_hex(name, version, repo) do
    case Hex.Repo.fetch_repo(repo) do
      {:ok, %{url: url}} ->
        purl(["hex", name], version, repository_url: url)

      :error ->
        raise "Undefined Hex repo: #{repo}"
    end
  end

  def git(_name, "git@github.com:" <> github, commit_or_tag) do
    github |> String.replace_suffix(".git", "") |> github(commit_or_tag)
  end

  def git(_name, "https://github.com/" <> github, commit_or_tag) do
    github |> String.replace_suffix(".git", "") |> github(commit_or_tag)
  end

  def git(_name, "git@bitbucket.org:" <> bitbucket, commit_or_tag) do
    bitbucket |> String.replace_suffix(".git", "") |> bitbucket(commit_or_tag)
  end

  def git(_name, "https://bitbucket.org/" <> bitbucket, commit_or_tag) do
    bitbucket |> String.replace_suffix(".git", "") |> bitbucket(commit_or_tag)
  end

  # Git dependence other than GitHub and BitBucket are not currently supported
  def git(_name, _git, _commit_or_tag), do: nil

  def github(github, commit_or_tag) do
    [organization, repository | _] = String.split(github, "/")
    name = repository |> String.downcase()
    purl(["github", String.downcase(organization), name], commit_or_tag)
  end

  def bitbucket(bitbucket, commit_or_tag) do
    [organization, repository | _] = String.split(bitbucket, "/")
    name = repository |> String.downcase()
    purl(["bitbucket", String.downcase(organization), name], commit_or_tag)
  end

  defp purl(type_namespace_name, version, qualifiers \\ []) do
    path =
      type_namespace_name
      |> Enum.map(&URI.encode/1)
      |> Enum.join("/")

    %URI{
      scheme: "pkg",
      path: "#{path}@#{URI.encode(version)}",
      query:
        case URI.encode_query(qualifiers) do
          "" -> nil
          query -> query
        end
    }
    |> to_string()
  end
end
