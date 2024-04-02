# Roact Navigation Version History

___
### master

Work in progress, to be added to next release notes.

### v0.5.10

* Added "non-transparent, see-through card" support to RobloxStackView ([#148](https://github.com/Roblox/roact-navigation-internal/pull/148))

### v0.5.9

* Fixed stack card transparency render optimization ([#146](https://github.com/Roblox/roact-navigation-internal/pull/146))

### v0.5.8

* Fixed stale navigation state bug for deep component trees ([#144](https://github.com/Roblox/roact-navigation-internal/pull/144))

### v0.5.7

* Fix index nil error in NavigationFocusEvents. ([#138](https://github.com/Roblox/roact-navigation-internal/pull/138))

### v0.5.6

* Add absorbInputSelectable as a screenOption for Stack navigators. This allows us to enable/disable gamepad selection for Stack cards. ([#135](https://github.com/Roblox/roact-navigation-internal/pull/135))

### v0.5.5

* Expose StackViewTransitionConfigs for custom navigator use ([#133](https://github.com/Roblox/roact-navigation-internal/pull/133))

### v0.5.4

* Optimize based on Universal App launch profiling ([#121](https://github.com/Roblox/roact-navigation-internal/pull/121))
* Emit willBlur event for removed screens during transitions ([#120](https://github.com/Roblox/roact-navigation-internal/pull/120))

### v0.5.3

* Fix JavaScript mistranslation in path parsing ([#116](https://github.com/Roblox/roact-navigation-internal/pull/116))

* Add useNavigation hook ([#115](https://github.com/Roblox/roact-navigation-internal/pull/115))

* Use unique key for stack screens rather than index ([#114](https://github.com/Roblox/roact-navigation-internal/pull/114))

### v0.5.2

* Fixed race condition in StackView Transitioner ([#111](https://github.com/Roblox/roact-navigation-internal/pull/111))
* Upgrade to Roact 17 ([#112](https://github.com/Roblox/roact-navigation-internal/pull/112))

### v0.5.1
* Updated the rotriever.toml to exclude the .robloxrc file from the package ([#109](https://github.com/Roblox/roact-navigation-internal/pull/109))
* Added back jest FakeTimer logic to align with upstream ([#108](https://github.com/Roblox/roact-navigation-internal/pull/108))

___
### v0.5.0

* Added compatibility for Roact 17 setState callbacks in createAppContainer dispatch and didMount. ([#104](https://github.com/Roblox/roact-navigation-internal/pull/104))
* Fix bug with StackView Transitioner where active screen content could remain hidden and prevent setState from being called while unmounting. ([#101](https://github.com/Roblox/roact-navigation-internal/pull/101))
* Allow for non-overlay screens to still use a transparent background and transparent background on non-overlay screens, change ClipsDescendants to false for navigator views and fix "Listener disconnected twice" error ([#97](https://github.com/Roblox/roact-navigation-internal/pull/97))
* Add `RoactNavigation.None` to allow removal of params ([#90](https://github.com/Roblox/roact-navigation-internal/pull/90))
* Add second optional parameter to `createAppContainer` to provide a LinkingProtocol object. This will be used when connecting the universal app to use deep-linking ([#83](https://github.com/Roblox/roact-navigation-internal/pull/83))
* Export `createSwitchNavigator`. ([#82](https://github.com/Roblox/roact-navigation-internal/pull/82))
* Implement `getActionForPathAndParams` and `getPathAndParamsForState` on routers to eventually support deep linking. ([#75](https://github.com/Roblox/roact-navigation-internal/pull/75))
* Align `createAppContainer` with React Navigation. ([#67](https://github.com/Roblox/roact-navigation-internal/pull/67))
* Prevent ref forwarding when the `withNavigation` config field `forwardRef` is false ([#73](https://github.com/Roblox/roact-navigation-internal/pull/73))

___
### v0.4.1

* Refactor navigation events handling to align with React Navigation. ([#65](https://github.com/Roblox/roact-navigation-internal/pull/65)). This should resolve issues with ordering and timing of blur and focus events.

___
### v0.4.0

* Add `SwitchView` and `createSwitchNavigator` from React Navigation. ([#58](https://github.com/Roblox/roact-navigation-internal/pull/58))
* Rename `StackView` to `RobloxStackView` and `createStackNavigator` to `createRobloxStackView` to make the deviation from upstream clear. ([#60](https://github.com/Roblox/roact-navigation-internal/pull/60))
* Rename `SwitchView` to `RobloxSwitchView` and `createSwitchNavigator` to `createRobloxSwitchNavigator` to reflect the differences with React Navigation `SwitchView` and `RobloxSwitchView`. ([#54](https://github.com/Roblox/roact-navigation-internal/pull/54))
* Stop supporting the routers API from 0.2.x (with the single parameter with the `routes` field). ([#49](https://github.com/Roblox/roact-navigation-internal/pull/49))
* Move `Navigations.CompleteTransition` into `StackActions` to align with React Navigation. ([#45](https://github.com/Roblox/roact-navigation-internal/pull/45))
* Rename `RoactNavigation.EventsAdapter` to `RoactNavigation.NavigationEvents` to align with React Navigation. The props from that component have also been aligned with upstream. See React Navigation [documentation](https://reactnavigation.org/docs/4.x/navigation-events/) ([#40](https://github.com/Roblox/roact-navigation-internal/pull/40))
* Align `withNavigation` and `withNavigationFocus` with React Navigation. Now, those function are higher-order components (HOC). See React Navigation [documentation](https://reactnavigation.org/docs/4.x/with-navigation/) for a concrete example. ([#44](https://github.com/Roblox/roact-navigation-internal/pull/44))
* Remove `RoactNavigation.connect`. The context provider now receives its value through the `value` prop (instead of `navigation`) ([#43](https://github.com/Roblox/roact-navigation-internal/pull/43))

___
### v0.3.0

This version has started to align with React Navigation a lot more. A part of React navigation test suite has been ported and multiple files have been refactored to align with their corresponding JavaScript version.

* Align SwitchRouter with React navigation ([#33](https://github.com/Roblox/roact-navigation-internal/pull/33))
* Rename event subscriber `disconnect` method to `remove` to match react-navigation ([#37](https://github.com/Roblox/roact-navigation-internal/pull/37))
* Remove unused RoactNavigation.None ([#32](https://github.com/Roblox/roact-navigation-internal/pull/32))
* StackRouter behavior now matches React-Navigation's StackRouter. StackActions.reset now requires the `index` field ([#28](https://github.com/Roblox/roact-navigation-internal/pull/28))
* Refactor TabRouter, SwitchRouter, StackRouter, createStackNavigator and createSwitchNagivator API. Previous API is deprecated but still supported. ([#27](https://github.com/Roblox/roact-navigation-internal/pull/27))

___
### v0.2.8

* Fixed bug with nested child transitions where trying to animate more than one screen at
a time could result in errors.
* Fixed bug that caused scenes to be spuriously remounted in stack navigation under some
circumstances.

___
### v0.2.7

* Fixed bug with navigationOptions.absorbInput on desktop.
* Fixed bug with passing arguments to getScreenProps() helper.
* Fixed bug with navigate() to current route with different params.

___
### v0.2.6

* Fixed additional race conditions in Transitioner and eliminated most of its reliance on spawn().
* Fixed spurious errors being generated by Transitioner position change callbacks when it tried
to index nil prevTransition.

___
### v0.2.5
* Updated dependencies to switch to Rotriever 0.4.x's url dependencies
* No changes to any functionality

___
### v0.2.4

* Fix for Transitioner race condition that causes Lua errors in complex configurations.
* Code docs for navigators/createSwitchNavigator.

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
