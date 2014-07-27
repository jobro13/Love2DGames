local stack = {}

function stack:new()
	local o = {data = {}}
	return setmetatable(o, {__index=stack})
end

-- pushes a value on the stack
function stack:push(value)

end

-- pops a value from the stack 
