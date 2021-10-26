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

This repo is using currently WIP library (mainly libadwaita). \
So if you want to build it yourself it is recommended to use flatpak-builder to build the included manifest.

The recommended way would be to build it from Gnome Builder.

**Currently NewCaw requires code not included in this repo to display a demonstration window, see the [linked discussion](https://github.com/CodedOre/NewCaw/discussions/4) for more detail.**

## Contributing

You can contribute in multiple ways:
- Review existing code for issues
- Fix some of the `FIXME` comments in the code
- Contribute a feature I'm yet to be working on, but please let me know in this case beforehand.
