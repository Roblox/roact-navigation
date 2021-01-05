-- upstream https://github.com/react-navigation/react-navigation/blob/9b55493e7662f4d54c21f75e53eb3911675f61bc/packages/native/src/createAppContainer.js

local Roact = require(script.Parent.Parent.Roact)
local Cryo = require(script.Parent.Parent.Cryo)
local NavigationActions = require(script.Parent.NavigationActions)
local Events = require(script.Parent.Events)
local NavigationContext = require(script.Parent.views.NavigationContext)
local getNavigation = require(script.Parent.getNavigation)
local invariant = require(script.Parent.utils.invariant)

local function isStateful(props)
	return not props.navigation
end

local function validateProps(props)
	if props.persistenceKey then
		warn(
			"You passed persistenceKey prop to a navigator. " ..
				"The persistenceKey prop was replaced by a more flexible persistence mechanism, " ..
				"please see the navigation state persistence docs for more information. " ..
				"Passing the persistenceKey prop is a no-op."
		)
	end
	if isStateful(props) then
		return
	end

	local containerProps = Cryo.Dictionary.join(props, {
		navigation = Cryo.None,
		screenProps = Cryo.None,
		persistNavigationState = Cryo.None,
		loadNavigationState = Cryo.None,
		-- deviation: no support for theme
		-- deviation: add key for external dispatch feature
		externalDispatchConnector = Cryo.None,
	})

	local keys = Cryo.Dictionary.keys(containerProps)

	if #keys ~= 0 then
		error(
			"This navigator has both navigation and container props, so it is " ..
				("unclear if it should own its own state. Remove props: %q "):format(
					table.concat(keys, ", ")
				) ..
				"if the navigator should get its state from the navigation prop. If the " ..
				"navigator should maintain its own state, do not pass a navigation prop."
		)
	end

	local persistNavigationState = props.persistNavigationState
	local loadNavigationState = props.loadNavigationState
	invariant(
		(persistNavigationState == nil and loadNavigationState == nil)
			or (typeof(persistNavigationState) == "function"
					and typeof(loadNavigationState) == "function"),
		"both persistNavigationState and loadNavigationState must either be undefined, or be functions"
	)
end

--[[
	Construct a container Roact component that will host the navigation hierarchy
	specified by your main AppComponent. AppComponent must be a navigator created by
	a Roact-Navigation helper function, or a stateful Roact component

	If you are using a custom stateful Roact component, make sure to set the 'router'
	field so that it can be hooked into the navigation system. You must also pass your
	'navigation' prop to any child navigators.

	Additional props:
		renderLoading    			- 	Roact component to render while the app is loading.
		externalDispatchConnector	-	Function that Roact Navigation can use to connect to
										externally triggered navigation Actions. This is useful
										for external UI or handling of the Android back button.

										Ex:
										local connector = function(rnDispatch)
											-- You store rnDispatch and call it when you want to inject
											-- an event from outside RN.
											return function()
												-- You disconnect rnDispatch when RN calls this.
											end
										end

										...
										Roact.createElement(MyRNAppContainer, {
											externalDispatchConnector = connector,
										})
]]
return function(AppComponent)
	invariant(type(AppComponent) == "table" and AppComponent.router ~= nil,
		"AppComponent must be a navigator or a stateful Roact component with a 'router' field")

	local containerName = string.format("NavigationContainer(%s)", tostring(AppComponent))
	local NavigationContainer = Roact.Component:extend(containerName)

	NavigationContainer.router = AppComponent.router

	function NavigationContainer.getDerivedStateFromProps(nextProps)
		validateProps(nextProps)
		return nil
	end

	function NavigationContainer:init()
		validateProps(self.props)

		self._actionEventSubscribers = {}
		self._initialAction = NavigationActions.init()

		local initialNav = nil
		local containerIsStateful = self:_isStateful()
		if containerIsStateful and not self.props.loadNavigationState then
			initialNav = AppComponent.router.getStateForAction(self._initialAction)
		end

		self.state = {
			nav = initialNav,
		}
	end

	function NavigationContainer:_updateExternalDispatchConnector()
		if self._disconnectExternalDispatch then
			self._disconnectExternalDispatch()
			self._disconnectExternalDispatch = nil
		end

		local externalDispatchConnector = self.props.externalDispatchConnector
		if externalDispatchConnector ~= nil then
			self._disconnectExternalDispatch = externalDispatchConnector(function(...)
				if self._isMounted then
					return self:dispatch(...)
				end

				-- External dispatch while we're not mounted gets dropped on floor.
				return false
			end)
		end
	end

	function NavigationContainer:_renderLoading()
		return self.props.renderLoading and self.props.renderLoading()
	end

	function NavigationContainer:_isStateful()
		return isStateful(self.props)
	end

	-- deviation: Not implementing _handleOpenURL because url features not implemented
	-- function NavigationContainer:_handleOpenURL(args)
	-- 	local url = args.url
	-- 	local enableURLHandling = self.props.enableURLHandling
	-- 	local uriPrefix = self.props.uriPrefix

	-- 	if enableURLHandling == false then
	-- 		return
	-- 	end
	-- 	local parsedUrl = urlToPathAndParams(url, uriPrefix)
	-- 	if parsedUrl then
	-- 		local path = parsedUrl.path
	-- 		local params = parsedUrl.params
	-- 		local action = AppComponent.router.getActionForPathAndParams(path, params);
	-- 		if action then
	-- 			self:dispatch(action)
	-- 		end
	-- 	end
	-- end

	function NavigationContainer:_onNavigationStateChange(prevNav, nextNav, action)
		local onNavigationStateChange = self.props.onNavigationStateChange

		if type(onNavigationStateChange) == "function" then
			onNavigationStateChange(prevNav, nextNav, action)
		end
	end

	function NavigationContainer:didUpdate(oldProps)
		-- Clear cached _navState every time we update.
		if self._navState == self.state.nav then
			self._navState = nil
		end

		if self.props.externalDispatchConnector ~= oldProps.externalDispatchConnector then
			self:_updateExternalDispatchConnector()
		end
	end

	function NavigationContainer:didMount()
		self._isMounted = true

		-- deviation: external dispatch connector
		self:_updateExternalDispatchConnector()

		if not self:_isStateful() then
			return
		end

		-- Pull out anything that can impact state
		-- deviation: url not supported
		-- local parsedUrl = nil
		local userProvidedStartupState = nil
		if self.props.enableURLHandling ~= false then
			local startupParams = self:getStartupParams()
			-- parsedUrl = startupParams.parsedUrl
			userProvidedStartupState = startupParams.userProvidedStartupState
		end

		-- Initialize state. This must be done *after* any async code
		-- so we don't end up with a different value for this.state.nav
		-- due to changes while async function was resolving
		local action = self._initialAction
		local startupState = self.state.nav

		if not startupState then
			startupState = AppComponent.router.getStateForAction(action)
		end

		-- Pull user-provided persisted state
		-- deviation: not implemented
		if userProvidedStartupState then
			startupState = userProvidedStartupState
		--   _reactNavigationIsHydratingState = true
		end

		-- Pull state out of URL
		-- deviation: url not implement
		-- if parsedUrl then
		-- 	local path = parsedUrl.path
		-- 	local params = parsedUrl.params
		-- 	local urlAction = AppComponent.router.getActionForPathAndParams(path, params)
		-- 	if urlAction then
		-- 		action = urlAction
		-- 		startupState = AppComponent.router.getStateForAction(
		-- 			urlAction,
		-- 			startupState
		-- 		)
		-- 	end
		-- end

		local function dispatchAction()
			-- _actionEventSubscribers maps callback to true, e.g. a Set container
			for subscriber in pairs(self._actionEventSubscribers) do
				subscriber({
					type = Events.Action,
					action = action,
					state = self.state.nav,
					lastState = nil,
				})
			end
		end

		if startupState == self.state.nav then
			-- This must be spawned until we get async setState callback handler in Roact
			spawn(dispatchAction)
			return
		end

		self:setState({
			nav = startupState
		})
	end

	-- deviation: url features not supported
	function NavigationContainer:getStartupParams()
		local props = self.props
		-- local uriPrefix = props.uriPrefix
		local loadNavigationState = props.loadNavigationState
		-- local url = nil
		local loadedNavState = nil
		pcall(function()
			-- url = Linking.getInitialURL(),
			loadedNavState = loadNavigationState and loadNavigationState()
		end)

		return {
			-- parsedUrl = url && urlToPathAndParams(url, uriPrefix),
			userProvidedStartupState = loadedNavState,
		}
	end

	-- deviation: no componentDidCatch lifecycle method in Roact

	function NavigationContainer:_persistNavigationState(nav)
		local persistNavigationState = self.props.persistNavigationState
		if persistNavigationState then
			local success, errorMessage = pcall(function()
				persistNavigationState(nav)
			end)

			if not success then
				warn(
					"Uncaught error while calling persistNavigationState()! "
						.. "You should handle exceptions thrown from persistNavigationState(), "
						.. "ignoring them may result in undefined behavior.\n"
						.. errorMessage
				)
			end
		end
	end

	function NavigationContainer:willUnmount()
		self._isMounted = false

		-- deviation: no url feature connected

		-- deviation: clean up externalDispatchConnector if necessary
		if self._disconnectExternalDispatch then
			self._disconnectExternalDispatch()
			self._disconnectExternalDispatch = nil
		end

		-- deviation: no stateful container count
		-- if self:_isStateful() then
		-- 	_statefulContainerCount = _statefulContainerCount - 1
		-- end
	end

	function NavigationContainer:dispatch(action)
		if self.props.navigation then
			return self.props.navigation.dispatch(action)
		end

		-- navState will have the most up-to-date value, because setState sometimes behaves asyncronously
		self._navState = self._navState or self.state.nav
		local lastNavState = self._navState
		invariant(lastNavState ~= nil, "should be set in constructor if stateful")

		local reducedState = AppComponent.router.getStateForAction(action, lastNavState)
		local navState = reducedState
		if reducedState == nil then
			navState = lastNavState
		end

		local function dispatchActionEvents()
			-- _actionEventSubscribers is a table(handler, true), e.g. a Set container
			for subscriber in pairs(self._actionEventSubscribers) do
				subscriber({
					type = Events.Action,
					action = action,
					state = navState,
					lastState = lastNavState,
				})
			end
		end

		if reducedState == nil then
			-- The router will return null when action has been handled and the state hasn't changed.
			-- dispatch returns true when something has been handled.
			dispatchActionEvents()
			return true
		end

		if navState ~= lastNavState then
			-- Cache updates to state.nav during the tick to ensure that subsequent calls
			-- will not discard this change
			self._navState = navState
			self:setState({ nav = navState })

			-- Must be spawned until we get async setState callback handler in Roact.
			spawn(function()
				self:_onNavigationStateChange(lastNavState, navState, action)
				dispatchActionEvents()
				self:_persistNavigationState(navState)
			end)

			return true
		end

		dispatchActionEvents()
		return false
	end

	-- deviation: additional functionality used in lua-apps
	function NavigationContainer:_getScreenProps(propKey, defaultValue)
		if propKey == nil then
			return self.props.screenProps
		end

		local screenProps = self.props.screenProps or {}

		if screenProps[propKey] == nil then
			return defaultValue
		end
		return screenProps[propKey]
	end

	-- deviation: removed '_getTheme' method because there is no support for theme

	function NavigationContainer:render()
		local navigation = self.props.navigation

		if self:_isStateful() then
			local navState = self.state.nav
			if not navState then
				return self:_renderLoading()
			end

			if not self._navigation or self._navigation.state ~= navState then
				self._navigation = getNavigation(
					AppComponent.router,
					navState,
					function(...)
						return self:dispatch(...)
					end,
					self._actionEventSubscribers,
					function(...)
						return self:_getScreenProps(...)
					end,
					function()
						return self._navigation
					end
				)
			end

			navigation = self._navigation
		end

		invariant(navigation ~= nil, "failed to get navigation")

		return Roact.createElement(NavigationContext.Provider, {
			value = navigation,
		}, {
			-- Provide navigation prop for top-level component so it doesn't have to connect.
			AppComponent = Roact.createElement(AppComponent, Cryo.Dictionary.join(self.props, {
				navigation = navigation,
			}))
		})
	end

	return NavigationContainer
end
