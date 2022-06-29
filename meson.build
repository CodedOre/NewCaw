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
  application_id = 'uk.co.ibboard.Cawbird.Devel'

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
  application_id = 'uk.co.ibboard.Cawbird'
  version = meson.project_version()
endif

message('Building ' + meson.project_name () + ' ' + version)

# Configure Mastodon platform
if get_option('mastodon_backend').enabled()
  add_project_arguments('-D', 'SUPPORT_MASTODON', language: 'vala')
endif

# Configure Twitter platform
if get_option('twitter_backend').enabled()
  add_project_arguments('-D', 'SUPPORT_TWITTER', language: 'vala')
  # Check for OAuth 2.0 key
  if get_option('twitter_oauth_key') == ''
    error('A client key needs to be provided for Twitter!')
  endif
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
