local Cryo = require(script.Parent.Parent.Parent.Parent.Cryo)
local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local Otter = require(script.Parent.Parent.Parent.Parent.Otter)
local AppNavigationContext = require(script.Parent.Parent.AppNavigationContext)
local NavigationActions = require(script.Parent.Parent.Parent.NavigationActions)
local StackActions = require(script.Parent.Parent.Parent.StackActions)
local StackHeaderMode = require(script.Parent.StackHeaderMode)
local StackPresentationStyle = require(script.Parent.StackPresentationStyle)
local NoneSymbol = require(script.Parent.Parent.Parent.NoneSymbol)
local StackViewTransitionConfigs = require(script.Parent.StackViewTransitionConfigs)
local StackViewCard = require(script.Parent.StackViewCard)
local SceneView = require(script.Parent.Parent.SceneView)
local TopBar = require(script.Parent.Parent.TopBar.TopBar)
local ContentHeightFitFrame = require(script.Parent.Parent.ContentHeightFitFrame)
local validate = require(script.Parent.Parent.Parent.utils.validate)

local StackViewLayout = Roact.Component:extend("StackViewLayout")

function StackViewLayout:init()
	self._isMounted = false
	self._scenesContainerRef = Roact.createRef()

	self._renderScene = function(scene)
		return self:_renderInnerScene(scene)
	end
end

function StackViewLayout:_getHeaderMode()
	if self.props.headerMode then
		return self.props.headerMode
	elseif self.props.mode == StackPresentationStyle.Modal then
		return StackHeaderMode.Screen
	else
		-- TODO: Change back to Float when TopBar implements it
		-- return StackHeaderMode.Float
		return StackHeaderMode.Screen
	end
end

function StackViewLayout:_renderHeader(scene, headerMode)
	local options = scene.descriptor.options
	local header = options.header

	validate(type(header) ~= "string",
		"header must be a valid Roact component, RoactNavigation.None, or nil, not a string")

	-- If HeaderMode is Screen and no header was explicitly removed from
	-- navigationOptions, then we do NOT want to render a header for this screen!
	if header == NoneSymbol and headerMode == StackHeaderMode.Screen then
		return nil
	end

	-- We will use header component if supplied, otherwise use default TopBar.
	local headerComponent = header ~= NoneSymbol and header or function(headerProps)
		return Roact.createElement(TopBar, headerProps)
	end

	local transitionProps = self.props.transitionProps or {}
	local passProps = Cryo.Dictionary.join(self.props, {
		transitionProps = Cryo.None,
	})

	return Roact.createElement(AppNavigationContext.Provider, {
		navigation = scene.descriptor.navigation,
	}, {
		["$header"] = Roact.createElement(headerComponent, Cryo.Dictionary.join(
			passProps,
			transitionProps, -- transitionProps override directly passed props
			{
				scene = scene,
				mode = headerMode,
			})
		)
	})
end

function StackViewLayout:_reset(resetToIndex, duration)
	local position = self.props.transitionProps.position

	position:setGoal(Otter.spring(resetToIndex, {
		frequency = 1 / duration,
	}))
end

function StackViewLayout:_goBack(backFromIndex, duration)
	local navigation = self.props.transitionProps.navigation
	local position = self.props.transitionProps.position
	local scenes = self.props.transitionProps.scenes

	local toValue = math.max(backFromIndex - 1, 1)

	-- Set up temporary completion handler
	local onCompleteDisconnector
	onCompleteDisconnector = position:onComplete(function()
		if onCompleteDisconnector then
			onCompleteDisconnector()
			onCompleteDisconnector = nil
		end

		local backFromScene
		for _, scene in ipairs(scenes) do
			if scene.index == toValue + 1 then
				backFromScene = scene
				break
			end
		end

		if backFromScene then
			navigation.dispatch(NavigationActions.back({
				key = backFromScene.route.key,
				immediate = true,
			}))

			navigation.dispatch(StackActions.completeTransition())
		end
	end)

	position:setGoal(Otter.spring(toValue, {
		frequency = 1 / duration,
	}))
end

function StackViewLayout:_onFloatingHeaderHeightChanged(height)
	local scenesContainer = self._scenesContainerRef.current
	if self._isMounted and scenesContainer then
		scenesContainer.Position = UDim2.new(0, 0, 0, height)
		scenesContainer.Size = UDim2.new(1, 0, 1, -height)
	end
end

function StackViewLayout:_renderCard(scene, index)
	local transitionProps = self.props.transitionProps -- Core animation info from Transitioner.
	local lastTransitionProps = self.props.lastTransitionProps -- Previous transition info.
	local transitionConfig = self.state.transitionConfig -- State based info from scene config.

	local initialPositionValue = transitionProps.scene.index
	if lastTransitionProps then
		initialPositionValue = lastTransitionProps.scene.index
	end

	local cardInterpolationProps = {}
	local screenInterpolator = transitionConfig.screenInterpolator
	if screenInterpolator then
		cardInterpolationProps = screenInterpolator(
			Cryo.Dictionary.join(transitionProps, {
				initialPositionValue = initialPositionValue,
				scene = scene,
			})
		)
	end

	-- Merge down the various prop packages to be applied to StackViewCard.
	return Roact.createElement(StackViewCard, Cryo.Dictionary.join(
		transitionProps, cardInterpolationProps, {
			ZIndex = index, -- later stack entries should render on top for animation purposes
			key = "card_" .. tostring(scene.key),
			scene = scene,
			renderScene = self._renderScene,
		})
	)
end

function StackViewLayout:_renderInnerScene(scene)
	local navigation = scene.descriptor.navigation

	local sceneComponent = scene.descriptor.getComponent()
	local screenProps = self.props.screenProps

	local sceneElement = Roact.createElement(SceneView, {
		screenProps = screenProps,
		navigation = navigation,
		component = sceneComponent,
	})

	local headerMode = self:_getHeaderMode()
	if headerMode == StackHeaderMode.Screen then
		--[[
			This ref is used to change the scene container size whenever the header changes height.
			It's not too expensive to create one every time this thing is rendered, and since it's
			not being set on the actual scene element then it won't trigger a bunch of reconciling
			beyond this immediate layer. Its lifetime is the same as the onSizeChanged callback.
		]]
		local sceneWrapperRef = Roact.createRef()

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			BorderSizePixel = 0,
		}, {
			screenHeader = Roact.createElement(ContentHeightFitFrame, {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				BorderSizePixel = 0,
				onHeightChanged = function(height)
					local sceneWrapper = sceneWrapperRef.current
					if self._isMounted and sceneWrapper then
						sceneWrapper.Position = UDim2.new(0, 0, 0, height)
						sceneWrapper.Size = UDim2.new(1, 0, 1, -height)
					end
				end
			}, {
				headerContent = self:_renderHeader(scene, headerMode)
			}),
			sceneWrapper = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				BorderSizePixel = 0,
				[Roact.Ref] = sceneWrapperRef,
			}, {
				scene = sceneElement,
			})
		})
	else
		return sceneElement
	end
end

function StackViewLayout:render()
	local headerMode = self:_getHeaderMode()
	local transitionProps = self.props.transitionProps
	local scenes = transitionProps.scenes

	local floatingHeader = nil

	if headerMode == StackHeaderMode.Float then
		local scene = transitionProps.scene
		floatingHeader = Roact.createElement(ContentHeightFitFrame, {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			BorderSizePixel = 0,
			onHeightChanged = function(...)
				self:_onFloatingHeaderHeightChanged(...)
			end
		}, {
			headerContent = self:_renderHeader(scene, headerMode)
		})
	end

	local renderedScenes = Cryo.List.map(scenes, function(scene, idx)
		return self:_renderCard(scene, idx)
	end)

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		BorderSizePixel = 0,
	}, {
		floatingHeader = floatingHeader or nil,
		scenesContainer = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0), -- Overridden by _onFloatingHeaderHeightChanged
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			BorderSizePixel = 0,
			[Roact.Ref] = self._scenesContainerRef,
		}, renderedScenes),
	})
end

function StackViewLayout.getDerivedStateFromProps(nextProps, lastState)
	return {
		transitionConfig = StackViewTransitionConfigs.getTransitionConfig(
			nextProps.transitionConfig,
			nextProps.transitionProps,
			nextProps.lastTransitionProps,
			nextProps.mode == StackPresentationStyle.Modal)
	}
end

function StackViewLayout:didMount()
	self._isMounted = true
end

function StackViewLayout:willUnmount()
	self._isMounted = false
end

return StackViewLayout
