# arbor.nvim

> Just like a true arborist, manage your worktrees in neovim.

## Development Status

I switched to using [jj](https://github.com/martinvonz/jj). It offers a workflow which I
prefer. In my case, there are almost no disadvantages to using it over git worktrees,
but there are plenty of improvements. I won't be actively developing arbor
anymore, but I will review and accept PRs.

## Contents

[Overview](#Overview)  
[Setup](#Setup)  
[Usage](#Usage)  
[Configuration](#Configuration)  
[Customization](#Customization)  
[What's Missing?](#Whats-Missing)  

## Overview

Honestly, it's probably not for most people. If you want a git worktree plugin,
take a look at
[git-worktree.nvim](https://github.com/ThePrimeagen/git-worktree.nvim) or
[polarmutex's fork of it](https://github.com/polarmutex/git-worktree.nvim).
Both are amazing plugins, and they work great. The reason I made this plugin, is
that git-worktree didn't play very nicely with my workflow, and it resulted in
a very large wrapper around the plugin to get what I wanted. I built arbor to 
address my problems with it.

### Arbor by design

I built arbor with one thing in mind: extensibility. At the heart of arbor,
there are two main features: the core features (add, pick, or remove a worktree)
and the actions. The actions are where you specify the additional functionality
that you want around the core features. As might have noticed, unlike
git-worktree, there is no "switch" feature. If you want a switch action, you
would specify it as an extended action to "pick".

### Extensibility

Actions come in two main flavors: hooks (pre and post) which are probably good
enough for most use-cases. You can also enable autocmds, by adding them to the
"events" table in your setup. They aren't enabled by default as I suspect that
most people won't need them, but they're there.

Actions are also selectable as items in the worktree pickers, and you can
customize which items show for each picker.

## Setup

All of the types are well documented, so if you have lua_ls, you should have
good autocomplete. The only exception is the select_opts table

### lazy.nvim

```lua
{
  "xavierchanth/arbor.nvim",
  ---@type arbor.config
  opts = {
    -- Your options go here
  }
}
```

## Usage

There are two ways to use arbor, with the `Arbor` exec command, or through the
lua API:

### Exec command

```sh
:Arbor pick
:Arbor add
:Arbor remove
```

Running just `:Arbor` is the same as `:Arbor pick`.

> At the moment the exec commands don't support passing arguments, this may be
> added at a later date upon request, please open an issue if you want this!

### Lua API

With the lua API, you gain the ability to override the default values of a
command, you can have have multiple `add`, `pick` or `remove` keymaps configured
in this way.

#### Pick

By default, there are some preset actions enabled in the options which make
nvim cd to the worktree. See [ACTIONS](./ACTIONS.md#Wrapping-Functions) for an example:

```lua
vim.keymap.set("n", "<leader>gw", function()
  require("arbor").pick()
end, {desc = "Pick worktree"})
```

<details>
<summary>Pick Options</summary>

```lua
require("arbor").pick({
  hooks = {
    pre = function(info) end, -- Add a pre-hook
    post = function(info) end, -- Add a post-hook
  },
  preserve_default_hooks = true, -- Whether to also run the hooks in your config
  select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection
  show_actions = true, -- show actions (the ones as selectable items)
  show_remote_branches = false, -- Include remote branches
})
```

</details>

#### Add

By default, the preset hook for add will track the upstream branch when adding
from a remote branch, or push an upstream branch when adding from a local branch.

```lua
vim.keymap.set("n", "<leader>ga", function()
  require("arbor").add()
end, {desc = "Add worktree"})
```


<details>
<summary>Add Options</summary>

```lua
require("arbor").add({
  hooks = {
    pre = function(info) end, -- Add a pre-hook
    post = function(info) end, -- Add a post-hook
  },
  preserve_default_hooks = true, -- Whether to also run the hooks in your config
  on_existing = function(info) end, -- Special hook to handle when the selected branch already exists
  on_add_failed = function(info, branch) end, -- Special hook to handle when git worktree add fails
  path_input_opts = nil, -- Table of input opts for path (currently takes a string for "prompt")
  branch_input_opts = nil, -- Table of input opts for branch (currently takes a string for "prompt")
  select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection
  path_style = "smart", -- How we detect path name for a git ref
  -- Other options: "same", "basename", "prompt", "path", function(git_info: arbor.git.info, local_branches?: string[]): string
  branch_style = "path", -- path will set the branch name to the same as the resolved path (relative to base)
  -- Other options: "prompt", function(git_info: arbor.git.info, local_branches?: arbor.git.branch[]): string
  show_remote_branches = true, -- Include remote branches
  branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)
  show_actions = true, -- Show actions by default
})
```

</details>

#### Remove

No preset hooks from remove, it just deletes the worktree. The branch is still
available locally. You could add a hook to remove the branch too, but make sure
you check that changes have been committed and pushed, otherwise you risk
losing work.

```lua
vim.keymap.set("n", "<leader>gr", function()
  require("arbor").remove()
end, {desc = "Remove worktree"})
```


<details>
<summary>Remove Options</summary>

```lua
require("arbor").remove({
  hooks = {
    pre = function(info) end, -- Add a pre-hook
    post = function(info) end, -- Add a post-hook
  },
  preserve_default_hooks = true, -- Whether to also run the hooks in your config
  select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection
  branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)
  show_actions = true, -- show actions as selectable items
  force = false, -- pass force to git worktree remove
})
```

</details>

## Configuration

The best way to see configuration is via the defaults.
All of the types are in config, so I suggest using the Lua annotation to enable
completion for the opts table if you have lua_ls setup.

In addition, you can explore [config.lua](./lua/arbor/config.lua),
[actions.lua](./lua/arbor/actions.lua), and the various actions in
[actions/](./lua/arbor/actions/). Actions are also covered in the next section,
[Customization](#Customization).

> If you are adventurous, there is also [types.lua](./lua/arbor/types.lua) which
> contains all of the type definitions for the config.

<details>
<summary>Default Configuration</summary>

  ```lua
---@type arbor.config
opts = {
	apply_recommended = true, -- apply recommended settings
	-- this is aimed at providing a better out of the box experience, but
	-- can be disabled for a cleaner base for adding customization
	select = "vim", -- Which selector to use, other options: "telescope", "fzf"
	input = "vim", -- Only vim is available right not (vim.ui.input)
	highlight = {
		action = "String", -- highlight group for actions when using telescope/fzf
		branch = "Function", -- highlight group for branches when using telescope/fzf
	},
	notify = {
		lib = false, -- suppress warnings about importing the arbor.lib
		---@type boolean
		enabled = true, -- whether to enable notifications
		---@type integer|nil
		level = nil, -- maximum level that logs will show for
		---@type table|nil
		opts = nil, -- options table to pass to vim.notify
	},
	settings = {
		add = {
			--- Input options
			path_input_opts = nil, -- Passed to vim.ui.input when prompted for worktree path
			branch_input_opts = nil, -- Passed to vim.ui.input when prompted for new branch name
			select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection

			--- Naming resolution
			path_style = "smart", -- How we detect path name for a git ref
			-- Other options: "same", "basename", "prompt", "path", function(git_info: arbor.git.info, local_branches?: string[]): string
			branch_style = "path", -- path will set the branch name to the same as the resolved path (relative to base)
			-- Other options: "prompt", function(git_info: arbor.git.info, local_branches?: arbor.git.branch[]): string

			--- Git options
			show_remote_branches = true, -- Include remote branches
			branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)
			show_actions = true, -- Show actions by default
		},
		remove = {
			select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection
			branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)

			--- Git options
			show_actions = true, -- show actions as selectable items
			force = false, -- pass force to git worktree remove
		},
		pick = {
			select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection

			--- Git options
			show_actions = true, -- show actions as selectable items
			show_remote_branches = false, -- Include remote branches
		},
	},
	git = {
		binary = "git", -- path to the git binary if it isn't on PATH
		main_branch = { "main", "master", "trunk" }, -- branch names to match as main
	},
	worktree = {
		normal = {
			base = "relative_common", -- Where to resolve the base of the repo from
			-- "relative_common" - relative to the git common dir (i.e. .git/)
			-- "relative_cwd" - relative to vim's cwd
			-- "absolute" - take path as it is
			path = "..", -- path to the base of the repo (relative to base, unless absolute is set)
		},
		bare = {
			base = "relative_common", -- same thing as above, but for bare repos
			path = ".",
		},
	},
	actions = {
		add = {}, -- pickable actions when running add()
		remove = {}, -- pickable actions when running remove()
		pick = {}, -- pickable actions when running pick()
	},
	hooks = { -- default hooks for each core feature
		pre_add = nil,
		post_add = nil,
		pre_remove = nil,
		post_remove = nil,
		pre_pick = nil,
		post_pick = nil,
	},
	events = {}, -- events to enable:
	-- ArborAddPre, ArborAddPost
	-- ArborRemovePre, ArborRemovePost
	-- ArborPickPre, ArborPickPost
}
```

</details>

## Customization

In short, customization is achieved via `actions` these are items that can be
added alongside branches in your pickers. They are also compliant as hooks
or autocmd callbacks. The actions library
[actions.lua](./lua/arbor/actions.lua), contains all of the actions predefined
by arbor. You can find the individual code in
[actions/](./lua/arbor/actions/) and require, copy or reference it to build
your own workflows.

> See [ACTIONS](./ACTIONS.md) for more in-depth information.

### Example 1 - Setup your keymaps

```lua
---lazy.nvim example
{
  "xavierchanth/arbor.nvim",
  keys = {
    {
      "<leader>ga",
      function()
        require("arbor").add()
      end,
      desc = "Git Worktree Add",
    },
    {
      "<leader>gw",
      function()
        require("arbor").pick()
      end,
      desc = "Git Worktree",
    },
  },
  ---@type arbor.config
  opts = {}
}
```

### Example 2 - Hooks

You can wrap hooks with as much logic as you want, and even share parts between
them. Here I show vim cd'ing to the chosen worktree for both add and pick.

```lua
local function arbor_post_switch(info)
  if info.new_path then
    require("arbor").actions.cd_new_path(info)
  else
    require("arbor").actions.cd_existing_worktree(info)
  end
end

opts = {

 hooks = {
    post_add = function(info)
      info = require("arbor").actions.set_upstream(info) or info
      arbor_post_switch(info)
    end,
    post_pick = arbor_post_switch
  }
}
```

### Example 3 - Pickable actions

This is how you would go about adding pickable actions to the core pickers.
These can be your own custom functions too.
```lua
opts = {
  actions = {
    add = {
      -- create a new branch + worktree from a selected base branch
      ["add new branch"] = function(info)
        -- This action is already available in arbor
        require("arbor").actions.add_new_branch(info)
      end,
    },
    pick = {
      -- Open a remove picker to delete a worktree
      ["remove worktree"] = function()
        require("arbor").remove()
      end,
    }
  }
}
```

## What's missing?

- I'm thinking about adding a picker for `git worktree move`, happy to do it if
it's asked for.
- I also plan to expand the actions library to cover more common use-cases.
- I would like to (carefully) expose some of the library code to make it easier
  to build custom actions. Right now there is `require("arbor").git` available.
- Telescope extension
- Something else? Please raise an issue!
- If you made a custom action because it wasn't available, please raise a PR or
  issue, so I can get it added to the plugin!

