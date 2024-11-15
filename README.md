# arbor.nvim

> Just like a true arborist, manage your worktrees in neovim.

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

```
{
  "xavierchanth/arbor.nvim",
  ---@type arbor.config
  opts = {
    -- Your options go here
  }
}
```

## Configuration

<details>
<summary>Default Configuration</summary>

  ```lua
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
			-- Other options: "same", "basename", "prompt", function(git_info: arbor.git.info, local_branches?: string[]): string
			branch_style = "path", -- path will set the branch name to the same as the resolved path (relative to base)
			-- Other options: "git", "prompt"

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
- There are no exec cmds yet, the only way to call the pickers is through lua.
- Something else? Please raise an issue!
- If you made a custom action because it wasn't available, please raise a PR or
  issue, so I can get it added to the plugin!

