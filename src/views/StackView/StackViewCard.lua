local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local validate = require(script.Parent.Parent.Parent.utils.validate)

--[[
	Render a scene inside a card for use in StackView. The content will be placed
	inside a floating colored card that sits above a customizable transparent
	background.

	Props:
		renderScene(scene)	-- Render prop to draw the scene inside the card.
		positionStep 		-- Stepper function from StackViewInterpolator.
		position			-- Otter motor for the position of the card.
		scene				-- Scene that the card is to render.

		overlayColor3		-- Color of the background overlay (default: black).
		overlayTransparency -- Transparency of the background overlay (default: 0.3).
		cardColor3			-- Color of the card (default: white).
		cardTransparency 	-- Transparency of the card (default: 0).
]]
local StackViewCard = Roact.Component:extend("StackViewCard")

StackViewCard.defaultProps = {
	overlayColor3 = Color3.new(0, 0, 0),
	overlayTransparency = 0.3,
	cardColor3 = Color3.new(255, 255, 255),
	cardTransparency = 0,
}

function StackViewCard:init()
	self._isMounted = false

	self._positionLastValue = self.props.navigation.state.index

	self.state = {
		visible = self.props.scene.isActive,
	}

	local selfRef = Roact.createRef()
	self._getRef = function()
		return self.props[Roact.Ref] or selfRef
	end
end

function StackViewCard:render()
	local visible = self.state.visible

	local scene = self.props.scene
	local renderScene = self.props.renderScene
	local overlayTransparency = self.props.overlayTransparency
	local overlayColor3 = self.props.overlayColor3

	validate(type(renderScene) == "function", "renderScene must be a function")

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = overlayTransparency,
		BackgroundColor3 = overlayColor3,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = visible,
		[Roact.Ref] = self:_getRef(),
	}, {
		["$content"] = renderScene(scene),
	})
end

function StackViewCard:didMount()
	self._isMounted = true

	local position = self.props.position
	self._positionDisconnector = position:onStep(function(...)
		self:_onPositionStep(...)
	end)
end

function StackViewCard:willUnmount()
	self._isMounted = false

	if self._positionDisconnector then
		self._positionDisconnector()
		self._positionDisconnector = nil
	end
end

function StackViewCard:didUpdate(oldProps)
	local position = self.props.position
	local positionStep = self.props.positionStep

	if position ~= oldProps.position then
		self._positionDisconnector()
		self._positionDisconnector = position:onStep(function(...)
			self:_onPositionStep(...)
		end)
	end

	if positionStep ~= oldProps.positionStep then
		-- The motor won't fire just because stepper function has changed. We have to
		-- update the position to match new requirements based upon last motor value.
		self:_onPositionStep(self._positionLastValue)
	end
end

function StackViewCard.getDerivedStateFromProps(props, state)
	return {
		-- change to visible if isActive changes to true, otherwise leave it
		-- at last value. This matches with _onPositionStep, below.
		visible = props.scene.isActive or state.visible,
	}
end

function StackViewCard:_onPositionStep(value)
	if not self._isMounted then
		return
	end

	local positionStep = self.props.positionStep
	local index = self.props.scene.index
	local isActive = self.props.scene.isActive
	local cardInVisibleRange = value < index + 1

	if positionStep then
		positionStep(self:_getRef(), value)
	end

	-- Note that isActive is also part of calculus for getDerivedStateFromProps!
	local visible = isActive or cardInVisibleRange
	if visible ~= self.state.visible then
		spawn(function()
			if self._isMounted then
				self:setState({
					visible = visible
				})
			end
		end)
	end

	self._positionLastValue = value
end

return StackViewCard
