# Deviations

One of the key advantages of aligning the Roact Navigation API with React Navigation (version 4) is that we can leverage their nice [documentation site](https://reactnavigation.org/docs/4.x/getting-started). However, there are some places where we need to deviate, because of the differences between JavaScript and Lua, or because of the Roblox environment.

This page will attempt to explain any known deviations between Roact Navigation and React Navigation.

### Some deviations to expect

The alignment process has mainly focused on the navigators behavior. We have imported a good part of the React Navigation test suite into our version to drive our alignment, but because of deviations between the React ecosystem and the current Roact, aligning the view part is more challenging. That is why our version does not have as much navigator creators as in React Navigation  ([`createBottomTabNavigator`](https://reactnavigation.org/docs/4.x/bottom-tab-navigator) or [`createDrawerNavigator`](https://reactnavigation.org/docs/4.x/drawer-navigator) for example).

Generally, you should expect deviations regarding anything visible to the eyes (topbars, animations). This document attempts to show deviations of the core mecanics of the library (when screens are focused or not, how to navigate to an other screen, etc).

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
createStackRouter({
	{ Profile = ProfileScreenComponent },
	{ Games = GamesScreenComponent },
})
```

If a specific route does not map to a component, but rather a config table, the same rule applies!

```lua
createStackRouter({
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

## BackBehavior

In **React** Navigation, when you need to specify the back behavior property (for a [SwitchNavigator](https://reactnavigation.org/docs/4.x/switch-navigator/#switchnavigatorconfig) for example), you use directly a string. In our version, you **can't use a string**, the different back behavior values are located under `RoactNavigation.BackBehavior`:

  - RoactNavigation.BackBehavior.None
  - RoactNavigation.BackBehavior.InitialRoute
  - RoactNavigation.BackBehavior.Order
  - RoactNavigation.BackBehavior.History

## `navigation.dangerouslyGetParent`

Since this function is not part of React Navigation 5, we prefer to remove it now make our future migration to version 5 easier. If you think you have a use case where `dangerouslyGetParent` appears to be a necessity, open an issue and we can engineer a solution for you.

## [`withNavigation`](https://reactnavigation.org/docs/4.x/with-navigation) and [`withNavigationFocus`](https://reactnavigation.org/docs/4.x/with-navigation-focus) [will align]

Both of these functions work differently than React Navigation. In [React Navigation](https://reactnavigation.org/docs/4.x/with-navigation/), they are higher order components that passes the `navigation` prop to the given component. Currently, our version is a thin wrapper over the navigation context render prop. Here's a summary of the API differences:

| version | input | output |
| -- | -- | -- |
| Roact | a function that will be called with the `navigation` prop | a Roact element |
| React | a component (stateful or functional) | a new component |

### Code example
In concrete, you would use the current Roact Navigation `withNavigation` or `withNavigationFocus` like this:
```lua
local function Foo(props)
	return withNavigation(function(navigation)
		return Roact.createElement(...)
	end)
end

return Foo
```

In a future release, we want to align with React Navigation, so the previous example would become:

```lua
local function Foo(props)
	local navigation = props.navigation

	return Roact.createElement(...)
end

return withNavigation(Foo)
```

This functionality already exist in Roact Navigation under another name: `RoactNavigation.connect`. With that being said, you should favor using `RoactNavigation.connect` as it will be easier to migrate later.

## `EventsAdapter` ([`NavigationEvents`](https://reactnavigation.org/docs/4.x/navigation-events) in React Navigation) [will align]

Currently, our version of this component has a different name and works like this:

```lua
Roact.createElement(RoactNavigation.EventsAdapter, {
	[RoactNavigation.Events.DidFocus] = <callback>,
	[RoactNavigation.Events.WillFocus] = <callback>,
	[RoactNavigation.Events.DidBlur] = <callback>,
	[RoactNavigation.Events.WillBlur] = <callback>,
})
```

In a future release, we want to align with React Navigation, which means the component will be renamed and the props too. The previous example would become:

```lua
Roact.createElement(RoactNavigation.NavigationEvents, {
	onDidFocus = <callback>,
	onWillFocus = <callback>,
	onDidBlur = <callback>,
	onWillBlur = <callback>,
})
```

## Events and [`addListenter`](https://reactnavigation.org/docs/4.x/navigation-prop#addlistener---subscribe-to-updates-to-navigation-lifecycle)

Instead of using strings for each event, Roact Navigation uses an enum (RoactNavigation.Events), so each React Navigation event maps to an entry of the enum:

```lua
"willFocus" => RoactNavigation.Events.WillFocus,
"didFocus" => RoactNavigation.Events.DidFocus,
"willBlur" => RoactNavigation.Events.WillBlur,
"didBlur" => RoactNavigation.Events.DidBlur,
```
