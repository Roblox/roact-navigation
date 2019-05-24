return function(target)
    local text = Instance.new("TextLabel")
    text.AnchorPoint = Vector2.new(0.5, 0.5)
    text.BackgroundColor3 = Color3.new(1,1,1)
    text.Font = Enum.Font.Gotham
    text.Position = UDim2.new(0.5,0,0.5,0)
    text.Size = UDim2.new(0.5,0,0.25,0)
    text.Text = "Hello, Horsecat!"
    text.TextColor3 = Color3.new(0,0,0)
    text.TextSize = 18

    text.Parent = target

    return function()
        text:Destory()
    end
end
