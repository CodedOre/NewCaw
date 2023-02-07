project(
  'Cawbird',
  ['vala', 'c'],
  version:        '1.9.0',
  meson_version:  '>= 0.59.0',
)
add_project_arguments('-DG_LOG_DOMAIN="cawbird"', language: 'c')

# Load meson modules
gnome = import('gnome')
i18n  = import('i18n')

# Set up translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Set build configuration
dev_build = get_option('buildtype') == 'debug' or get_option('buildtype') == 'debugoptimized'
if dev_build
  add_project_arguments('-D', 'DEBUG', language: 'vala')
  application_id = 'uk.co.ibboard.Cawbird.Devel'

  # Create a version number based on the git commit for development versions
  git = find_program('git', required : false, disabler : true)
  if git.found()
    # Get short version of commit id and use it as version number
    git_branch = run_command(git, 'rev-parse', '--abbrev-ref', 'HEAD', check: true)
    git_commit = run_command(git, 'rev-parse', '--short', 'HEAD', check: true)
    version = git_branch.stdout().strip() + '-' + git_commit.stdout().strip()
  else
    # Use project version as fallback
    version = meson.project_version() + '-devel'
  endif
else
  # Use project version in release builds
  application_id = 'uk.co.ibboard.Cawbird'
  version = meson.project_version()
endif

message('Building ' + meson.project_name () + ' ' + version)

# Configure Backends
mastodon_backend = get_option('backends') == 'Mastodon' or get_option('backends') == 'Full'

# Configure Mastodon platform
if mastodon_backend
  add_project_arguments('-D', 'SUPPORT_MASTODON', language: 'vala')
endif

# Build and test the backend from subdirectories
subdir('lib')
# FIXME: We need new tests
# subdir('tests')

# Build the code and data for the client
cawresources = []
subdir('data')
subdir('ui')
subdir('src')

# Add the translations
subproject('po')

# Run post-install actions
gnome.post_install(
     glib_compile_schemas: true,
    gtk_update_icon_cache: true,
  update_desktop_database: true
)