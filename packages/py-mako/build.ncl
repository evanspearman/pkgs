let { Attrs, BuildSpec, Local, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in

let python = import "../python/build.ncl" in
let setuptools = import "../setuptools/build.ncl" in
let py-markupsafe = import "../py-markupsafe/build.ncl" in

let version = "1.4.3" in
{
  name = "py-mako",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://files.pythonhosted.org/packages/source/m/mako/mako-%{version}.tar.gz",
      sha256 = "cd6537fe88d5fec315c55c2f8529bc4ce7a9a352ad7db3eeaa6a66e2dd4ec37a",
      extract = true,
      strip_prefix = "mako-%{version}",
    } | Source,
    base,
  ],

  runtime_deps = [
    python,
    setuptools,
    py-markupsafe,
  ],

  cmd = "./build.sh",

  outputs = {
    python_site_package = { glob = "usr/lib/python*/site-packages/mako/**" } | OutputData,
    python_dist_info = { glob = "usr/lib/python*/site-packages/[Mm]ako-*.dist-info/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      source_provenance = {
        category = 'GithubRepo,
        owner = "sqlalchemy",
        repo = "mako",
      },
    } | Attrs,

  tests = {
    smoketest =
      {
        class = 'Standalone,
        test_deps = [python],
        cmds = [
          ["/usr/bin/python3", "-c", "from mako.template import Template; r = Template(\"hi ${x|h}\").render(x=\"<b>\"); assert r == \"hi &lt;b&gt;\", r; print(r)"],
        ],
      } | Test,
  },
} | BuildSpec
