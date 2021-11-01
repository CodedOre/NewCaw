libtests = {
  'Parsing': {
    'MediaParsing': [
      'TestUtils.vala',
      'Parsing/MediaChecks.vala',
      'Parsing/MediaParsing.vala',
      'Parsing/PostChecks.vala',
      'Parsing/UserChecks.vala'
    ],
    'PostParsing': [
      'TestUtils.vala',
      'Parsing/PostChecks.vala',
      'Parsing/PostParsing.vala',
      'Parsing/UserChecks.vala'
    ],
    'UserParsing': [
      'TestUtils.vala',
      'Parsing/UserChecks.vala',
      'Parsing/UserParsing.vala'
    ]
  }
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
