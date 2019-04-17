-- Generator information:
-- Human name: Roact Navigation
-- Variable name: RoactNavigation
-- Repo name: roact-navigation

return {
    createTopBarStackNavigator = require(script.createTopBarStackNavigator),
    createBottomTabNavigator = require(script.createBottomTabNavigator),

    EventsAdapter = require(script.views.NavigationEventsAdapter),

    withNavigation = require(script.views.withNavigation),

    Events = require(script.NavigationEvents),
    Actions = require(script.NavigationActions),
    StackActions = require(script.StackActions),
}
