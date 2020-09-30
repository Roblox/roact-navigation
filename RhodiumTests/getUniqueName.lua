local counter = math.random(1, 10000)

return function()
	counter = counter + 1
	return ("Root%d"):format(counter)
end
