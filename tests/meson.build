libtests = {
}

testdepends = declare_dependency(
  link_with:            backendlib,
  include_directories:  backendsrc,
  dependencies:         libdepends
)

foreach category, tests : libtests
  foreach name, sources : tests
    testcase = executable(
      name,
      sources,
      dependencies: testdepends
    )
    test(
      name,
      testcase,
      suite: category,
      workdir: meson.project_source_root() + '/tests/' + category
    )
  endforeach
endforeach
