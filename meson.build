project(
  'Cawbird',
  ['vala', 'c'],
  version:        '1.9.0',
  meson_version:  '>= 0.56.0',
)

# Load meson modules
gnome = import('gnome')
i18n  = import('i18n')

# Set up translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Set build configuration
if get_option('buildtype') == 'debug' or get_option('buildtype') == 'debugoptimized'
  add_project_arguments('-D', 'DEBUG', language: 'vala')

  # Create a version number based on the git commit for development versions
  git = find_program('git', required : false, disabler : true)
  if git.found()
    # Get short version of commit id and use it as version number
    git_branch = run_command(git, 'rev-parse', '--abbrev-ref', 'HEAD')
    git_commit = run_command(git, 'rev-parse', '--short', 'HEAD')
    version = git_branch.stdout().strip() + '-' + git_commit.stdout().strip()
  else
    # Use project version as fallback
    version = meson.project_version() + '-devel'
  endif
else
  # Use project version in release builds
  version = meson.project_version()
endif

message('Building ' + meson.project_name () + ' ' + version)

# Configure supported platforms
if get_option('support_mastodon')
  add_project_arguments('-D', 'SUPPORT_MASTODON', language: 'vala')
endif
if get_option('support_twitter')
  add_project_arguments('-D', 'SUPPORT_TWITTER', language: 'vala')
endif
if get_option('support_twitter_legacy')
  add_project_arguments('-D', 'SUPPORT_TWITTER_LEGACY', language: 'vala')
endif

# Build and test the backend from subdirectories
subdir('lib')
subdir('tests')

# Build the code and data for the client
cawresources = []
subdir('data')
subdir('ui')
subdir('src')

# Add the translations
subproject('po')

# Add post-install script
meson.add_install_script('build-aux/meson-postinstall.py')
