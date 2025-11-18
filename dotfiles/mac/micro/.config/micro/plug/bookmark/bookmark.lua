VERSION = "3.0.0"

local micro = import("micro")
local buffer = import("micro/buffer")
local config = import("micro/config")

local HISTORY_LIMIT = 20
local history = {}
local history_index = 0
local skip_recording_for = nil
local last_lines = {}

local function buffer_key(buf)
	if buf == nil then
		return nil
	end

	if buf.AbsPath ~= nil and buf.AbsPath ~= "" then
		return buf.AbsPath
	end

	return buf:GetName()
end

local function clone_loc(loc)
	return { X = loc.X, Y = loc.Y }
end

local function loc_equals(a, b)
	if a == nil or b == nil then
		return false
	end
	return a.X == b.X and a.Y == b.Y
end

local function entry_equals(a, b)
	if a == nil or b == nil then
		return false
	end
	return a.name == b.name and loc_equals(a.loc, b.loc)
end

local function build_entry(bp)
	local cursor = bp.Buf:GetActiveCursor()
	return {
		pane = bp,
		buf = bp.Buf,
		name = bp.Buf:GetName(),
		path = bp.Buf.AbsPath,
		loc = clone_loc(cursor.Loc)
	}
end

local function redraw_buffer(buf)
	if buf == nil then
		return
	end

	buf:ClearMessages("bookmark")

	local has_entry = false
	for idx, entry in ipairs(history) do
		if entry.buf == buf then
			has_entry = true
			local label = string.format("history %d/%d", idx, #history)
			if idx == history_index then
				label = label .. " (current)"
			end
			_gutter(buf, label, entry.loc.Y + 1)
		end
	end

	if not has_entry then
		_gutter(buf, "", 0)
	end
end

local function trim_history()
	if #history <= HISTORY_LIMIT then
		return
	end

	local overflow = #history - HISTORY_LIMIT
	for _ = 1, overflow do
		local removed = table.remove(history, 1)
		if removed ~= nil then
			redraw_buffer(removed.buf)
		end
		if history_index > 0 then
			history_index = history_index - 1
		end
	end

	if history_index < 1 and #history > 0 then
		history_index = 1
	end
end

local function record_position(bp, force)
	if bp == nil or bp.Buf == nil then
		return
	end

	if skip_recording_for == bp then
		skip_recording_for = nil
		return
	end

	local cursor = bp.Buf:GetActiveCursor()
	local line = cursor.Loc.Y
	local key = buffer_key(bp.Buf)

	if not force then
		local last = key and last_lines[key] or nil
		if last ~= nil and last == line then
			return
		end
	end

	if key ~= nil then
		last_lines[key] = line
	end

	local entry = build_entry(bp)
	local last = history[#history]

	if not force and entry_equals(last, entry) then
		return
	end

	if history_index > 0 and history_index < #history then
		for i = #history, history_index + 1, -1 do
			local removed = table.remove(history, i)
			if removed ~= nil then
				redraw_buffer(removed.buf)
			end
		end
	end

	table.insert(history, entry)
	trim_history()
	history_index = #history
	redraw_buffer(entry.buf)
end

local function tab_index_for(target_tab)
	local tabs = micro.Tabs()
	if tabs == nil or tabs.List == nil or type(tabs.List) ~= "table" then
		return nil
	end

	for i = 1, #tabs.List do
		local tab = tabs.List[i]
		if tab == target_tab then
			return i - 1
		end
	end

	return nil
end

local function pane_index_for(tab, target_pane)
	if tab == nil or tab.Panes == nil or type(tab.Panes) ~= "table" then
		return nil
	end

	for i = 1, #tab.Panes do
		local pane = tab.Panes[i]
		if pane == target_pane then
			return i - 1
		end
	end

	return nil
end

local function ensure_active_pane(entry)
	if entry == nil or entry.pane == nil then
		return nil
	end

	local pane = entry.pane
	local tab = pane:Tab()

	if tab == nil or pane.Buf == nil or pane.Buf ~= entry.buf then
		return nil
	end

	local ti = tab_index_for(tab)
	if ti ~= nil then
		micro.Tabs():SetActive(ti)
	end

	local pi = pane_index_for(tab, pane)
	if pi ~= nil then
		tab:SetActive(pi)
	end

	return pane
end

local function drop_entry(index)
	local removed = history[index]
	table.remove(history, index)
	if history_index > #history then
		history_index = #history
	end
	if history_index < 0 then
		history_index = 0
	end
	if removed and removed.buf then
		redraw_buffer(removed.buf)
	end
end

local function jump_to(index, bp)
	if index < 1 or index > #history then
		return
	end

	local entry = history[index]
	local previous = history[history_index]
	local previous_buf = previous and previous.buf or nil
	local pane = ensure_active_pane(entry)

	if pane == nil then
		drop_entry(index)
		if bp ~= nil then
			_redraw(bp)
		end
		return
	end

	local cursor = pane.Buf:GetActiveCursor()
	cursor:GotoLoc(buffer.Loc(entry.loc.X, entry.loc.Y))
	cursor:ResetSelection()
	pane:Relocate()

	history_index = index
	skip_recording_for = pane
	redraw_buffer(pane.Buf)
	if previous_buf ~= nil and previous_buf ~= pane.Buf then
		redraw_buffer(previous_buf)
	end
end

local function clamp_index(pos)
	if pos < 1 then
		return 1
	end
	if pos > #history then
		return #history
	end
	return pos
end

function _toggle(bp)
	record_position(bp, true)
end

function _clear(bp)
	local cleared_buffers = {}
	for _, entry in ipairs(history) do
		if entry.buf ~= nil then
			cleared_buffers[entry.buf] = true
		end
	end

	history = {}
	history_index = 0
	skip_recording_for = nil

	for buf in pairs(cleared_buffers) do
		redraw_buffer(buf)
		local key = buffer_key(buf)
		if key ~= nil then
			last_lines[key] = nil
		end
	end
end

function _next(bp)
	if #history == 0 then
		return
	end
	if history_index >= #history then
		return
	end
	jump_to(clamp_index(history_index + 1), bp)
end

function _prev(bp)
	if #history == 0 then
		return
	end
	if history_index <= 1 then
		return
	end
	jump_to(clamp_index(history_index - 1), bp)
end

function onCursorMove(bp)
	record_position(bp, false)
end

local function record_active_pane(force)
	local pane = micro.CurPane()
	if pane ~= nil then
		record_position(pane, force or false)
	end
end

function onBufPaneOpen(bp)
	record_position(bp, true)
end

function onSetActive(bp)
	record_position(bp, true)
end

function onAnyEvent()
	record_active_pane(false)
end

function onQuit(bp)
	if bp == nil then
		return
	end

	for i = #history, 1, -1 do
		if history[i].pane == bp or history[i].buf == bp.Buf then
			drop_entry(i)
		end
	end

	if bp.Buf ~= nil then
		local key = buffer_key(bp.Buf)
		if key ~= nil then
			last_lines[key] = nil
		end
	end
end

function _redraw(bp)
	if bp and bp.Buf then
		redraw_buffer(bp.Buf)
	end
end

function _gutter(target, msg, line)
	if target == nil then
		return
	end

	target:AddMessage(buffer.NewMessageAtLine("bookmark", msg, line, buffer.MTInfo))
end

function init()
	config.MakeCommand("toggleBookmark", _toggle, config.OptionComplete)
	config.MakeCommand("nextBookmark", _next, config.OptionComplete)
	config.MakeCommand("prevBookmark", _prev, config.OptionComplete)
	config.MakeCommand("clearBookmarks", _clear, config.OptionComplete)

	-- config.TryBindKey("Ctrl-F2", "command:toggleBookmark", false)
	-- config.TryBindKey("CtrlShift-F2", "command:clearBookmarks", false)
	config.TryBindKey("Alt-.", "command:nextBookmark", false)
	config.TryBindKey("Alt-,", "command:prevBookmark", false)

	config.AddRuntimeFile("bookmark", config.RTHelp, "help/bookmark.md")
end
