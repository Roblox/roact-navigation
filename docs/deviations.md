# Deviations

One of the key advantages of aligning the Roact Navigation API with React Navigation (version 4) is that we can leverage their nice [documentation site](https://reactnavigation.org/docs/4.x/getting-started). However, there are some places where we need to deviate, because of the differences between JavaScript and Lua, or because of the Roblox environment.

This page will attempt to explain any known deviations between Roact Navigation and React Navigation.

### Some deviations to expect

The alignment process has mainly focused on the navigators behavior. We have imported a good part of the React Navigation test suite into our version to drive our alignment, but because of deviations between the React ecosystem and the current Roact, aligning the view part is more challenging. That is why our version does not have as much navigator creators as in React Navigation  ([`createBottomTabNavigator`](https://reactnavigation.org/docs/4.x/bottom-tab-navigator) or [`createDrawerNavigator`](https://reactnavigation.org/docs/4.x/drawer-navigator) for example).

Generally, you should expect deviations regarding anything visible to the eyes (topbars, animations). To highlight this fact, the navigators and views have been prefixed with `Roblox`. For example, you'll find `createRobloxStackNavigator` or `createRobloxSwitchNavigator` which use `RobloxStackView` and `RobloxSwitchView` respectively.

This document attempts to show deviations of the core mecanics of the library (when screens are focused or not, how to navigate to an other screen, etc).

## [Themes](https://reactnavigation.org/docs/4.x/themes)

Anything related to theming has not been imported into Roact Navigation.

## Routes config

When specifying the route config, usually with [`createStackNavigator`](https://reactnavigation.org/docs/4.x/stack-navigator/#routeconfigs) or [`createSwitchNavigator`](https://reactnavigation.org/docs/4.x/switch-navigator/#routeconfigs), the routes are passed differently.

In JavaScript, key-value pairs are ordered in a map, as in Lua, they are not. Because of that, we can't have the same structure for our `routeConfig` parameter.

For example, in **React** Navigation, you could have this following route config passed to `createStackRouter`:

```js
// JavaScript
createStackRouter({
	Profile: ProfileScreenComponent,
	Games: GamesScreenComponent,
})
```

In **Roact** Navigation, we wrap each key-value pair in its own table, so the routeConfig is actually an array. That let Roact Navigation know the order of the routes and the initial route.

```lua
createRobloxStackRouter({
	{ Profile = ProfileScreenComponent },
	{ Games = GamesScreenComponent },
})
```

If a specific route does not map to a component, but rather a config table, the same rule applies!

```lua
createRobloxStackRouter({
	{
		Profile = {
			getScreen = function()
				return ProfileScreenComponent
			end
		}
	},
	{ Games = GamesScreenComponent },
})
```

## Null paths in route config

In upstream, you can set the `path` property of a route to prevent this route to match againts empty paths. To have the same behavior in Luau, we expose `RoactNavigation.DontMatchEmptyPath`. For example:

```js
StackRouter({
	foo: { screen: FooNavigator, path: null },
})
```

Would translate to the following Luau code

```lua
StackRouter({
	{ foo = { screen = FooNavigator, path = RoactNavigation.DontMatchEmptyPath } },
})
```

## URLs parsing is case sensitive

Because the underlying regular expression library does not support case insensitiveness, URL parsing will be case sensitive.

## Actions

The different actions under NavigationActions, StackActions and SwitchActions do not have the same casing as in React Navigation. However, the action creators match, simply just not the action types themselves. There is a good chance you won't need those, but here are the differences:

| React Navigation | Roact Navigation |
| -- | -- |
| `NavigationActions.BACK` | `NavigationActions.Back` |
| `NavigationActions.INIT` | `NavigationActions.Init` |
| `NavigationActions.NAVIGATE` | `NavigationActions.Navigate` |
| `NavigationActions.SET_PARAMS` | `NavigationActions.SetParams` |
| `StackActions.POP` | `StackActions.Pop` |
| `StackActions.POP_TO_TOP` | `StackActions.PopToTop` |
| `StackActions.PUSH` | `StackActions.Push` |
| `StackActions.RESET` | `StackActions.Reset` |
| `StackActions.REPLACE` | `StackActions.Replace` |
| `StackActions.COMPLETE_TRANSITION` | `StackActions.CompleteTransition` |
| `SwitchActions.JUMP_TO` | `SwitchActions.JumpTo` |

## BackBehavior

In **React** Navigation, when you need to specify the back behavior property (for a [SwitchNavigator](https://reactnavigation.org/docs/4.x/switch-navigator/#switchnavigatorconfig) for example), you use directly a string. In our version, you **can't use a string**, the different back behavior values are located under `RoactNavigation.BackBehavior`:

  - RoactNavigation.BackBehavior.None
  - RoactNavigation.BackBehavior.InitialRoute
  - RoactNavigation.BackBehavior.Order
  - RoactNavigation.BackBehavior.History

## `navigation.dangerouslyGetParent`

Since this function is not part of React Navigation 5, we prefer to remove it now make our future migration to version 5 easier. If you think you have a use case where `dangerouslyGetParent` appears to be a necessity, open an issue and we can engineer a solution for you.

## Events and [`addListener`](https://reactnavigation.org/docs/4.x/navigation-prop#addlistener---subscribe-to-updates-to-navigation-lifecycle)

Instead of using strings for each event, Roact Navigation uses an enum (RoactNavigation.Events), so each React Navigation event maps to an entry of the enum:

```lua
"willFocus" => RoactNavigation.Events.WillFocus,
"didFocus" => RoactNavigation.Events.DidFocus,
"willBlur" => RoactNavigation.Events.WillBlur,
"didBlur" => RoactNavigation.Events.DidBlur,
```
