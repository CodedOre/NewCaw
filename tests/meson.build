# Tests for the backend library

# Define all tests with category and files
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

# Set the test dependencies
testdepends = declare_dependency(
  link_with:            backendlib,
  include_directories:  backendsrc,
  dependencies:         libdepends
)

# Build and run each test
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
