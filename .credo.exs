%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/doc/"]
      },
      strict: true,
      color: true,
    }
  ]
}
