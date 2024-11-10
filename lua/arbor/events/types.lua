---@meta

---@class arbor.hooks
---@field pre_add? arbor.hooks.pre
---@field post_add? arbor.hooks.post
---@field pre_delete? arbor.hooks.pre
---@field post_delete? arbor.hooks.post
---@field pre_switch? arbor.hooks.pre
---@field post_switch? arbor.hooks.post
---@field pre_move? arbor.hooks.pre
---@field post_move? arbor.hooks.post

---@class arbor.hooks.pre_spec: arbor.git.hooks_base_spec
---@field branch string
---@field path string
---@field repo_type arbor.git.repo_type
---@field common_dir string
---@field resolved_base string

---@class arbor.hooks.post_spec: arbor.git.hooks_base_spec
---@field branch string -- refers to previous/deleted branch
---@field path string -- refers to previous/deleted path
---@field remote? string
---@field new_branch? string -- refers to the new/current branch
---@field new_path? string -- refers to the new/current branch
---@field repo_type arbor.git.repo_type
---@field common_dir string
---@field resolved_base string

---@alias arbor.hooks.pre function(spec: arbor.hooks.pre_spec): arbor.hooks.pre_spec
---@alias arbor.hooks.post function(spec: arbor.hooks.post_spec): arbor.hooks.post_spec

---@class arbor.hooks.spec
---@field pre? arbor.hooks.pre
---@field post? arbor.hooks.post
