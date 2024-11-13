---@class arbor.actions
---@field add_new_branch arbor.actions.add_new_branch
---@field cd_existing_worktree arbor.action
---@field cd_new_path arbor.action
---@field fetch arbor.actions.fetch
---@field push_upstream arbor.actions.push_upstream
---@field tcd_existing_worktree arbor.action
---@field tcd_new_path arbor.action

---@alias arbor.actions.add_new_branch
---| function(info?: arbor.git.info, opts?:arbor.opts.add): arbor.git.info|nil

---@alias arbor.actions.fetch
---| function(info?: arbor.git.info, opts?:arbor.opts.fetch.opts): arbor.git.info|nil

---@alias arbor.actions.push_upstream
---| function(info?: arbor.git.info, opts?:arbor.opts.push_upstream.opts): arbor.git.info|nil

-- TODO import from external files, so all actions are not loaded with this file

-- TODO:
-- git fetch
-- git pull
-- git push
-- prompt for branch if detached
-- infer branch from path
-- custom branch naming example
-- custom path naming example

---# Actions
---
---## For Arbor Users
---
---### Quick definition on "Actions"
---
---Note that there two things that we are referring to when we say "actions":
---
---1. An item you can pick in one of arbor's pickers that calls a function
---2. Those underlying functions which also are also plug & play with arbor's
---events (i.e. hooks and autocmd callbacks).
---
---### Overview
---
---Actions are designed such that they conform as valid function apis for
---hooks, autocmd callbacks (for arbor's autocmds), or as entries in any of
---the pickers.
---
--- TODO: example of an action in all 3 contexts
---
---Note that just because a particular action is compliant as all three, it
---doesn't mean that it's well suited or designed to be used in that way.
---
---If you want to see a full list of functions, each one has it's own dedicated
---file in the repo under lua/arbor/actions. This also makes it easy to see
---what the action is doing.
---
---### Wrapping Functions
---
---You can also wrap an action in a function to add even more custom behavior
---around it, just note that that wrapper must accept an arbor.git.info? as
---the first argument, and depending on the context, not all of the fields
---may be populated (those that are marked as non-null will always be available
---though).
---
--- TODO: wrapped function example
---
---### Lifecycle
---
---Because Arbor offers several ways to handle events, it may be important for
---you to know how they work if you are using multiple in the same context.
---
---The main lifecycle:
---
---1. Get the main choice from the picker
---2a. If main choice was an action, just run the action and don't do anything else
---2b. If main choice was a branch, get any other input needed to resolve it.
---3a. If Arbor<context>Pre event is enabled, execute that autocmd
---3b. If preserve_default_hooks=true in opts and you've provided a pre hook in
---    the opts, run it.
---3c. If you have provided a pre hook in the opts run it.
---4.  Run the context's main action
---5a. If preserve_default_hooks=true in opts and you've provided a post hook in
---    the opts, run it.
---5b. If you have provided a post hook in the opts run it.
---5c. If Arbor<context>Post event is enabled, execute that autocmd
---
---Note the order of the hooks, your hooks can return an arbor.git.info
---table to overwrite what get's passed into the next event in the lifecycle.
---
---This means you can use hooks to modify what gets passed to the main action
---and the Arbor<context>Post autocmd.
---
---> Side note: I was debating whether the Pre event should be allowed to be
---> rewritten by hooks, but it isn't useful, since you will likely disrupt
---> what get's passed to the main context. You can also exec an autocmd from
---> your hook if you really need to.
---
---## For Developers:
---
---In order to enable this high level of plug & play, there are some minor
---sacrifices that we had to make to the actions api.
---
---First and foremost, all actions must expect arbor.git.info as the first
---argument. The action can allow this argument to be optional, but in order
---to be compliant as a hook, action, or arbor autocmd, this must be the first
---argument.
---
---You can add any other arguments you want to an action, however they must be
---optional, otherwise they won't be plug & play.
---
---A good example of both of these is arbor.actions.add_new_branch
---
---

local M = {}

setmetatable(M, {
	__index = function(_, k)
		return require("arbor.actions." .. k)
	end,
})

return M
