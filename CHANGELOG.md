# Roact Navigation Version History

### master

Work in progress, to be added to next release notes.

___
### v0.2.4

- Fix for Transitioner race condition that causes Lua errors in complex configurations.
- Code docs for navigators/createSwitchNavigator.

___
### v0.2.3

___This is an API breaking change!___

Changes:

* Replaced AppContainer.backActionSignal with AppContainer.externalDispatchConnector
to allow external code to inject arbitrary navigation actions.

___
### v0.2.2

Changes:

* Add keepVisitedScreensMounted feature to SwitchNavigator.
* Fixed a typo in SceneReducer, to allow proper update of scene descriptors.
* Linter fixes submitted by `jtaylor`.

___
### v0.2.1

Changes:

* Update some files and tests so that they play nice when Roact Navigation
is imported as a dependency under arbitrary folder paths. (Previously it
only worked correctly when the top-level folder name was "RoactNavigation".)

___
### v0.2.0

___This is an API breaking change!___

Changes:

* createTopBarStackNavigator and createBottomBarSwitchNavigator have been
removed. It is now the responsibility of higher-level libraries to manage
the visual aspects of navigation UI. This decision was made because most
applications need to do some level of customization to their nav bars.
It is therefor useful to write those parts in a separate module to allow
for overriding or wholistic replacement.
* Added mechanism to draw a static-position UI behind every game card. This
allows for custom backgrounds and animations to be stacked up in between cards.
* Added mechanism to listen for transition state changes so that you can
synchronize any navigation UI animations with Roact Navigation's internal changes.
* From this version the only valid Screen Components are:
	* Roact Function Component and
	* Roact Stateful Component
* Roact Navigation now uses Rotriever registry dependencies.

___
### v0.1.3
Changes:

* This version fixes compatibility problems with Roact 1.x. From 0.1.0 to
0.1.1, we regressed a bugfix for complex navigator hierarchies when
running against Roact 1.x. (The new async setState in Roact 1.x changes
our timing, so RN needs different code to mesh with the new behavior).

* In essence, RN 0.1.0 is compatible with Roact 1.x, but 0.1.1 and 0.1.2
are not compatible. You should uptake 0.1.3 if you need to use the
old-style APIs for navigation bars and require Roact 1.x compatibility.

___
### v0.1.2

Changes:

* Fixed setState timing bugs in StackView where programmatically
navigating during initial mounting would lead to bad visual state.
* Cleaned up public API of unusable bottom bar components.
* Fixed failure for StackNavigator.reset() where RN was internally
calculating the wrong index, which leads to what is essentially an
internal inconsistency error.

___
### v0.1.1b

This is a special re-release of v0.1.1 with linter fixes contributed by
`jtaylor`. No other code changes are included.

___
### v0.1.1

This version of Roact Navigation is the last update before all of the
visual adornments are moved out of the core implementation into a
separate repository so that they can take advantage of other libraries
like UIBlox.

Changes:

* Alleviated bugs with DidFocus not firing for the last screen if the
user navigates while a transition is already ongoing, or the developer
mistakenly writes in multiple navigation action calls in response to a
button click.
* Missing entrypoints for stack navigator related views were added to
init.lua.
* Bottom bar elements are removed.
* Unit tests are now in \_tests\_ subdirectories.
* Git submodules use https links to make it easier to download
dependencies via Github app tokens.

___
### v0.1.0

This tag represents the first version of roact-navigation that is
considered to be relatively stable. It is currently missing the
following major features that are required for functional
completeness:
* Bottom Tab Navigator
* Side Tab Navigator
* Blur support for modal/overlay stack navigation
* Comprehensive documentation

The following features are considered functionally complete, but may
have bugs or are lacking in polish:

* App Container (host for nav other nav components)
* Switch Navigator (flat page list without extra UI)
* Stack Navigator (left-right, modal, and overlay modes)
* Navigation Context helpers
* withNavigation* helpers
* EventsAdapter helper
