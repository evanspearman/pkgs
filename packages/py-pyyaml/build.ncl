let { Attrs, BuildSpec, Local, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in

let python = import "../python/build.ncl" in
let setuptools = import "../setuptools/build.ncl" in

let version = "6.0.4" in
{
  name = "py-pyyaml",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://files.pythonhosted.org/packages/source/p/pyyaml/pyyaml-%{version}.tar.gz",
      sha256 = "e24bf71af8a432d7808fabff134d38dfe16d3cbb41f2873bb4b1e42422de0a1a",
      extract = true,
      strip_prefix = "pyyaml-%{version}",
    } | Source,
    base,
  ],

  runtime_deps = [
    python,
    setuptools,
  ],

  cmd = "./build.sh",

  outputs = {
    python_site_package = { glob = "usr/lib/python*/site-packages/yaml/**" } | OutputData,
    python_dist_info = { glob = "usr/lib/python*/site-packages/[Pp]y[Yy][Aa][Mm][Ll]-*.dist-info/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      source_provenance = {
        category = 'GithubRepo,
        owner = "yaml",
        repo = "pyyaml",
      },
    } | Attrs,

  tests = {
    smoketest =
      {
        class = 'Standalone,
        test_deps = [python],
        cmds = [
          ["/usr/bin/python3", "-c", "import yaml; assert yaml.safe_load(\"a: [1, 2]\") == {\"a\": [1, 2]}; print(yaml.safe_dump({\"a\": 1}))"],
        ],
      } | Test,
  },
} | BuildSpec
