local api = vim.api

-- Buffer within the window
local buf

-- Window containing the bibliography
local win

local function trim_string(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Get the screen dimensions
--
-- Returns a table with width (cols in the screen) and height (rows in the buffer)
local function screen_dimensions()
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

	return {
		width = width,
		height = height
	}
end

-- Gets the content of a bib file
local function get_bib_content()
	local file = io.open(api.nvim_get_var("citatie_bib_files")[1], "r")
	local contents = file:read("*all")
	file:close()
	return contents
end

-- Parses a bib file to an list of strings
local function parse_bib_file()
	local bib = get_bib_content()
	local parsed = {}
	local i = 0

	for line in bib:gmatch("([^\n]*)\n?") do
		-- Trim the line
		line = trim_string(line)

		-- Line is a title
		local line_lower = string.lower(line)
		if (line_lower:match("^(.*) *=")) == "title" then
			local title = ""

			if line:match("({.*})") ~= nil then
				title = line:match("{(.*)}")
			elseif line:match("(\".*\")") then
				title = line:match("\"(.*)\"")
			end

			parsed[i] = parsed[i] .. " - " .. title

			goto continue
		end

		-- Is not a new section
		if line:sub(1, 1) ~= "@" then
			goto continue
		end

		i = i + 1
		parsed[i] = line:match("@.*{(.+),")

		::continue::
	end

	return parsed
end

-- Closes the current window
local function close_window()
	api.nvim_win_close(win, true)
end

-- Event handler for selecting of an entry
--
-- Mode is the way to export the citation key (i.e. [@key] or @[key])
function select_entry(mode)
	local input = api.nvim_get_current_line()
	local value
	close_window()

	local key = input:match("^(.-) %-")

	-- Check for mode
	if mode == "full" then
		value = "[@" .. key .. "]"
	elseif mode == "inline" then
		value = "@" .. key
	else
		print("[citatie] Invalid mode given")
		return
	end

	api.nvim_input("i" .. value .. "<ESC>")
end

-- Sets the mapping for the main buffer
--
-- `<cr>` Selects a current citation in full mode
-- `f` Selects a current citation in full mode
-- `i` Selects a current citation in inline mode
local function mappings()
	local map_config = { nowait = true, noremap = true, silent = true }
	local map = {
		["<CR>"] = "select_entry('full')",
		["f"] = "select_entry('full')",
		["i"] = "select_entry('inline')"
	}

	-- Map the keybinds
	for k, v in pairs(map) do
		api.nvim_buf_set_keymap(buf, "n", k, 
			':lua require"citatie".'..v..'<CR>', map_config)
	end

	-- Map the other keys to nothing
	local other_chars = {"a", "b", "c", "d", "e", "g", "h", "l", "q", "k", "n",
		"o", "p", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

	for k, v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, "n", v, "", map_config)
		api.nvim_buf_set_keymap(buf, "n", v:upper(), "", map_config)
		api.nvim_buf_set_keymap(buf, "n",  "<c-"..v..">", "", map_config)
	end
end

-- Opens a window to select a citation
local function open_window()
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

	local window_size = screen_dimensions()

	-- Windows size
    local win_height = math.ceil(window_size.height * 0.5 - 4)

    -- and finally create it with buffer attached
    win = api.nvim_open_win(buf, true, {
		style = "minimal",
		relative = "editor",
		anchor = "SW",
		width = window_size.width,
		height = win_height,
		row = window_size.height,
		col = window_size.width,
		border = "single"
	})

	local bib_content = parse_bib_file()
	api.nvim_buf_set_lines(buf, 0, -1, false, bib_content)
	mappings()
end

return {
	open_window = open_window,
	select_entry = select_entry
}
