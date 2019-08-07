--[[
	Provides builders to create functions that interpolate the current Otter motor
	position into the correct translation for stack cards based upon their associated
	scene.

	Interpolator builders expect the following props as input:
	{
		navigation = <standard Roact-Navigation prop with state info>,
		scene = <scene for the particular card being animated>,
		layout = {
			initWidth = <expected width of card>,
			initHeight = <expected height of card>,
			isMeasured = <boolean: true if initWidth+Height have been measured, else false>,
		}
	}

	Each builder returns a props table to be merged onto your other StackViewCard props, ex:
	{
		positionStep = <stepper function, or nil if not needed>,
		Position = <default position UDim2 for card>,
		Visible = false, -- May disable card visibility if it's outside interpolating range.
	}

	The props table may contain other changes, depending on the requirements of the animation.
]]
local getSceneIndicesForInterpolationInputRange = require(
	script.Parent.Parent.Parent.utils.getSceneIndicesForInterpolationInputRange)

-- Helper interpolates t with range [0,1] into the range [a,b].
local function lerp(a, b, t)
	return a * (1 - t) + b * t
end

-- Render initial style when layout hasn't been measured yet.
local function forInitial(props)
	local navigation = props.navigation
	local scene = props.scene

	local focused = navigation.state.index == scene.index
	local translate = not focused and 1000000 or 0 -- unfocused = far far away!

	return {
		Visible = focused, -- hide scene if not focused
		Position = UDim2.new(0, translate, 0, translate),
		positionStep = nil,
	}
end

-- Slide-in from right style (e.g. navigation stack view).
local function forHorizontal(props)
	local layout = props.layout
	local scene = props.scene

	if not layout.isMeasured then
		return forInitial(props)
	end

	local interpolate = getSceneIndicesForInterpolationInputRange(props)

	-- getSceneIndices* returns nil if card is not visible and need not be
	-- considered for the animation until state changes.
	if not interpolate then
		return {
			Visible = false,
			positionStep = nil,
		}
	end

	local first = interpolate.first
	local last = interpolate.last
	local index = scene.index

	local width = layout.initWidth

	local function stepper(cardRef, positionValue)
		local cardInstance = cardRef.current
		if not cardInstance then
			return
		end

		-- 3 range LERP
		local xPosition
		if positionValue < first then
			xPosition = width
		elseif positionValue < index then
			xPosition = lerp(width, 0, (positionValue - first) / (index - first))
		elseif positionValue == index then
			xPosition = 0
		elseif positionValue < last then
			xPosition = lerp(0, -width, (positionValue - index) / (last - index))
		else
			xPosition = -width
		end

		local oldPosition = cardInstance.Position
		cardInstance.Position = UDim2.new(
			oldPosition.X.Scale,
			xPosition,
			oldPosition.Y.Scale,
			oldPosition.Y.Offset
		)
	end

	return {
		positionStep = stepper,
	}
end

-- Slide-in from bottom style (e.g. modals).
local function forVertical(props)
	local layout = props.layout
	local scene = props.scene

	if not layout.isMeasured then
		return forInitial(props)
	end

	local interpolate = getSceneIndicesForInterpolationInputRange(props)

	if not interpolate then
		return {
			Visible = false,
			positionStep = nil,
		}
	end

	local first = interpolate.first
	local index = scene.index
	local height = layout.initHeight

	local function stepper(cardRef, positionValue)
		local cardInstance = cardRef.current
		if not cardInstance then
			return
		end

		-- 2 range LERP
		local yPosition
		if positionValue < first then
			yPosition = height
		elseif positionValue < index then
			yPosition = lerp(height, 0, positionValue / (index - first))
		else
			yPosition = 0
		end

		local oldPosition = cardInstance.Position
		cardInstance.Position = UDim2.new(
			oldPosition.X.Scale,
			oldPosition.X.Offset,
			oldPosition.Y.Scale,
			yPosition
		)
	end

	return {
		positionStep = stepper,
	}
end

return {
	forHorizontal = forHorizontal,
	forVertical = forVertical,
}
