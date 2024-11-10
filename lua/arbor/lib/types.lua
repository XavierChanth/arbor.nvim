---@meta

---@class arbor.git.path_base_spec
---@field branch string
---@field path string
---@field repo_type arbor.git.repo_type
---@field common_dir string

---@class arbor.git.hooks_base_spec : arbor.git.path_base_spec
---@field branch string
---@field path string
---@field repo_type arbor.git.repo_type
---@field common_dir string
---@field resolved_base string

---@class arbor.git.internal_base_spec : arbor.git.hooks_base_spec
---@field branch string
---@field path string
---@field repo_type arbor.git.repo_type
---@field common_dir string
---@field resolved_base? string

---@alias arbor.git.repo_type
---| "bare"
---| "normal"

---@alias arbor.worktree.style
---| "relative_common"
---| "relative_cwd"
---| "absolute"

---@alias arbor.config.worktree.path
---| string
---| function(spec: arbor.git.path_base_spec): string

---@class arbor.git.worktree.add : arbor.core_item
---@class arbor.git.worktree.switch : arbor.core_item
---@class arbor.git.worktree.delete : arbor.core_item
