# NewCaw
This may be the future Cawbird!

## Introduction

This is the repository for the ongoing work on NewCaw, a rewrite of [Cawbird](https://github.com/ibboard/cawbird).

It covers the following goals:
- Rewrite the UI in GTK4 and libadwaita, following the current Gnome HIG
- Rewrite the backend in a better extendable structure in Vala
- Provide support for the upcoming API v2.0 for Twitter
- [If possible] Provide support for the Mastodon API

When the work will be completed, the code in this repo will become Cawbird 2.0.

## Building

The recommended way to build this project is with Gnome Builder, which will use flatpak-builder to get the dependencies and build it.

In order to build the Twitter backend, you need to supply an client key for an OAuth 2.0 application via the `twitter_oauth_key` build option.

## Contributing

This is a large project, so every help is appreachiated! You can always review the code or take a look at the posted issues. There are also features that are yet to be implemented where you can work on, so get in touch if you want to help with that!
