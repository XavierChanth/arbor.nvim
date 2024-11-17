# Actions

## For Arbor Users

### Quick definition on "Actions"

Note that there two things that we are referring to when we say "actions":

1. An item you can pick in one of arbor's pickers that calls a function
2. Those underlying functions which also are also plug & play with arbor's
events (i.e. hooks and autocmd callbacks).

### Overview

Actions are designed such that they conform as valid function apis for
hooks, autocmd callbacks (for arbor's autocmds), or as entries in any of
the pickers.

Note that just because a particular action is compliant as all three, it
doesn't mean that it's well suited or designed to be used in that way.

If you want to see a full list of functions, each one has it's own dedicated
file in the repo under [lua/arbor/actions](lua/arbor/actions). This also makes
it easy to see what the action is doing.

### The actions API

All actions conform to the same base requirements, they receive the git_info
table as the first argument. The git_info table has the following definition.

```lua
---@class arbor.git.info
---@field operation_opts? arbor.opts -- opts passed to the current feature (add/pick/remove)
---@field branch string -- the starting branch
---@field cwd string -- vim's cwd
---@field toplevel string -- git top level from the cwd (nearest parent .git)
---@field repo_type arbor.git.repo_type -- "normal" or "bare"
---@field common_dir string -- git common dir path
---@field resolved_base? string -- resolved repo base based on your current config
---@field branch_info? arbor.git.branch -- information about the selected branch
---@field new_path? string -- new path if relevant
---@field new_branch? string -- new branch if relevant
```

Note that some actions may take additional arguments, and can be wrapped in
order to pass those arguments. For example, with the fetch action:

```lua
-- this is from lua/arbor/actions/fetch.lua
local function git_fetch(info, opts)
	opts = opts or {}
	local args = opts.fetch_args or {}
	table.insert(args, 1, "fetch")
	local job = require("arbor.git").job({
		args = args,
		cwd = opts.cwd or (info and info.common_dir),
    --- parts omitted for brevity...
	})
	job:sync()
end
```

You can pass options to it like so:

```lua
local function fetch_hook(info)
  return git_fetch(info, {
    -- pass your options here
    cwd = my_cwd_function()
    fetch_args = { "--all" }
  })
end
```

### Wrapping Functions

You can also wrap an action in a function to add even more custom behavior
around it, just note that that wrapper must accept an arbor.git.info? as
the first argument, and depending on the context, not all of the fields
may be populated (those that are marked as non-null will always be available
though).

```lua
local function is_valid_switch(info)
  return not (info.repo_type ~= "bare" and info.cwd == info.resolved_base and info.cwd == info.branch_info.new_path)
end

function M.arbor_post_switch(info)
  if is_valid_switch(info) then
    if info.new_path then
      require("arbor").actions.cd_new_path(info)
    else
      require("arbor").actions.cd_existing_worktree(info)
    end
    M.arbor_set_dashboard(info) -- Set the dashboard with worktree name (function omitted for brevity)
    vim.cmd("bufdo bd")
  else
    vim.notify("Already on this worktree")
  end
end
```

### Lifecycle

Because Arbor offers several ways to handle events, it may be important for
you to know how they work if you are using multiple in the same context.

The main lifecycle:

1. Get the main choice from the picker
2. If main choice was an action, just run the action and don't do anything else
3.   If main choice was a branch, get any other input needed to resolve it.
4. If Arbor\<context>Pre event is enabled, execute that autocmd
5. If preserve_default_hooks=true in opts and you've provided a pre hook in
    the opts, run it.
6. If you have provided a pre hook in the opts run it.
7.  Run the context's main action
8. If preserve_default_hooks=true in opts and you've provided a post hook in
    the opts, run it.
9. If you have provided a post hook in the opts run it.
10. If Arbor\<context>Post event is enabled, execute that autocmd

Note the order of the hooks, your hooks can return an arbor.git.info
table to overwrite what get's passed into the next event in the lifecycle.

This means you can use hooks to modify what gets passed to the main action
and the Arbor\<context>Post autocmd.

> Side note: I was debating whether the Pre event should be allowed to be
> rewritten by hooks, but it isn't useful, since you will likely disrupt
> what get's passed to the main context. You can also exec an autocmd from
> your hook if you really need to.

## For Developers:

In order to enable this high level of plug & play, there are some minor
sacrifices that we had to make to the actions api.

First and foremost, all actions must expect arbor.git.info as the first
argument. The action can allow this argument to be optional, but in order
to be compliant as a hook, action, or arbor autocmd, this must be the first
argument.

You can add any other arguments you want to an action, however they must be
optional, otherwise they won't be plug & play.

A good example of both of these is arbor.actions.add_new_branch
