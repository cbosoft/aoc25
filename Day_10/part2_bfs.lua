-- https://stackoverflow.com/a/27028488
local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


local function array_copy_append(arr, last)
  local arr2 = {}
  for _, v in ipairs(arr) do
    table.insert(arr2, v)
  end
  table.insert(arr2, last)
  return arr2
end


local function apply_action(action, state)
  local new_state = {}
  for i, v in ipairs(state) do
    new_state[i] = v
  end
  for _, v in ipairs(action) do
    new_state[v+1] = new_state[v+1] + 1
  end
  return new_state
end


local function check(p, q)
  local rv = 0
  for i, v in ipairs(p) do
    if v > q[i] then
      return 1
    elseif v < q[i] then
      rv = -1
    end
  end
  return rv
end


local function bfs(initial_state, goal, actions)
  local steps = { { history=0, state=initial_state} }
  local next_steps = { }
  while true do
    for _, step in ipairs(steps) do
      for _, action in ipairs(actions) do
        local next_state = apply_action(action, step.state)
        local next_history = step.history + 1
        local next_step = { history=next_history, state=next_state }
        local check_result = check(next_state, goal)
        if check_result == 0 then
          return next_step
        elseif check_result < 0 then
          table.insert(next_steps, next_step)
        else
          -- purge this timeline
        end
      end
    end

    steps = next_steps
    print(#steps)
    next_steps = {}
  end
end

local function parse_instruction(line)
  -- line is like "[<goal>]"
  local _, j = string.find(line, "%[.*%]")
  -- local lights_str = string.sub(line, i+1, j-1)
  local k, l = string.find(line, "{.*}")
  local joltage_str = string.sub(line, k+1, l-1)
  local buttons_str = string.sub(line, j+1, k-1)

  local goal_state = {}
  local initial_state = {}
  for si in string.gmatch(joltage_str, "([^,]+)") do
    table.insert(goal_state, tonumber(si))
    table.insert(initial_state, 0)
  end

  local buttons = {}
  -- https://stackoverflow.com/a/7615129
  for si in string.gmatch(buttons_str, "([^%s]+)") do
    local indices_str = string.sub(si, 2, #si - 1)
    local indices = {}
    for sj in string.gmatch(indices_str, "([^,]+)") do
      table.insert(indices, tonumber(sj))
    end
    table.insert(buttons, indices)
  end

  return { goal_state=goal_state, initial_state=initial_state, buttons=buttons}
end

local function main()
  local instructions = {}
  local line = io.read()
  while line ~= nil do
    local instruction = parse_instruction(line)
    table.insert(instructions, instruction)
    print("line", line)
    print("  goal:", dump(instruction.goal_state))
    print("  init:", dump(instruction.initial_state))
    print("  btns:", dump(instruction.buttons))
    line = io.read()
  end

  local sum = 0
  for _, i in ipairs(instructions) do
    local res = bfs(i.initial_state, i.goal_state, i.buttons)
    sum = sum + res.history
    print("Result:", dump(res.history), res.history, dump(res.state), dump(i.goal_state))
  end
  print(sum)
end

main()
