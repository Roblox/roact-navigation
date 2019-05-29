local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

return function(target)
    local FirstPage = Roact.Component:extend("FirstPage")

    function FirstPage:render()
        local navigation = self.props.navigation
        return Roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0.5,0,0.25,0),
            Text = "Hello, Roact-Navigation page 1!",
            TextColor3 = Color3.new(0,0,0),
            TextSize = 18,
            [Roact.Event.Activated] = function()
                navigation.navigate("Page2")
            end,
        })
    end

    local function SecondPage(props)
        return Roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0.5,0,0.25,0),
            Text = "Hello, Roact-Navigation page 2!",
            TextColor3 = Color3.new(0,0,0),
            TextSize = 18,
            [Roact.Event.Activated] = function()
                props.navigation.navigate("Page3")
            end,
        })
    end

    local ThirdPage = Roact.Component:extend("ThirdPage")

    function ThirdPage:render()
        local navigation = self.props.navigation

        return Roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0.5,0,0.25,0),
            Text = "Hello, Roact-Navigation page 3A!",
            TextColor3 = Color3.new(0,0,0),
            TextSize = 18,
            [Roact.Event.Activated] = function()
                navigation.navigate("Page3B")
            end,
        })
    end

    local function FourthPage(props)
        local navigation = props.navigation

        return Roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0.5,0,0.25,0),
            Text = "Hello, Roact-Navigation page 3B!",
            TextColor3 = Color3.new(0,0,0),
            TextSize = 18,
            [Roact.Event.Activated] = function()
                navigation.navigate("Page1")
            end,
        })
    end

    local ThirdPageNavigator = RoactNavigation.createSwitchNavigator({
        routes = {
            Page3A = ThirdPage,
            Page3B = FourthPage,
        },
        initialRouteName = "Page3A",
    })

    local rootNavigator = RoactNavigation.createSwitchNavigator({
        routes = {
            Page1 = FirstPage,
            Page2 = SecondPage,
            Page3 = ThirdPageNavigator,
        },
        initialRouteName = "Page1",
    })

    local appContainer = RoactNavigation.createAppContainer(rootNavigator)

    local tree = Roact.createElement("Folder", nil, {
        appContainer = Roact.createElement(appContainer)
    })

    local rootInstance = Roact.mount(tree, target)

    return function()
        Roact.unmount(rootInstance)
    end
end
