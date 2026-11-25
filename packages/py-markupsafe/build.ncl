let { Attrs, BuildSpec, Local, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in

let python = import "../python/build.ncl" in
let setuptools = import "../setuptools/build.ncl" in

let version = "3.0.4" in
{
  name = "py-markupsafe",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://files.pythonhosted.org/packages/source/m/markupsafe/markupsafe-%{version}.tar.gz",
      sha256 = "2e9ad7dd851bf45fab9f75cbff4cb493fee9979e8d8c7c9c3ee119022518edd6",
      extract = true,
      strip_prefix = "markupsafe-%{version}",
    } | Source,
    base,
  ],

  runtime_deps = [
    python,
    setuptools,
  ],

  cmd = "./build.sh",

  outputs = {
    python_site_package = { glob = "usr/lib/python*/site-packages/markupsafe/**" } | OutputData,
    python_dist_info = { glob = "usr/lib/python*/site-packages/[Mm]arkup[Ss]afe-*.dist-info/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "BSD-3-Clause",
      source_provenance = {
        category = 'GithubRepo,
        owner = "pallets",
        repo = "markupsafe",
      },
    } | Attrs,

  tests = {
    smoketest =
      {
        class = 'Standalone,
        test_deps = [python],
        cmds = [
          ["/usr/bin/python3", "-c", "from markupsafe import escape; assert str(escape(\"<b>\")) == \"&lt;b&gt;\"; print(escape(\"<b>\"))"],
        ],
      } | Test,
  },
} | BuildSpec
