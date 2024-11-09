---@meta

---@class arbor.hooks.info
---@field branch? string
---@field path? string

---@class arbor.hooks.info.pre : arbor.hooks.info

---@class arbor.hooks.info.post : arbor.hooks.info
---@field exit_code integer

---@class arbor.hooks.info.change_branch : arbor.hooks.info
---@field prev_branch? string

---@class arbor.hooks.info.change_path : arbor.hooks.info
---@field prev_path? string

-- ADD

---@class arbor.hooks.info.pre.add : arbor.hooks.info.pre

---@alias arbor.hooks.pre.add
---| function(info: arbor.hooks.info.pre.add): arbor.hooks.info.pre.add

---@class arbor.hooks.info.post.add : arbor.hooks.info.post

---@alias arbor.hooks.post.add
---| function(info: arbor.hooks.info.post.add): arbor.hooks.info.post.add

-- DELETE

---@class arbor.hooks.info.pre.delete : arbor.hooks.info.pre

---@alias arbor.hooks.pre.delete
---| function(info: arbor.hooks.info.pre.delete): arbor.hooks.info.pre.delete

---@class arbor.hooks.info.post.delete : arbor.hooks.info.post

---@alias arbor.hooks.post.delete
---| function(info: arbor.hooks.info.post.delete): arbor.hooks.info.post.delete

-- SWITCH

---@class arbor.hooks.info.pre.switch : arbor.hooks.info.pre
---@class arbor.hooks.info.pre.switch : arbor.hooks.info.change_path
---@class arbor.hooks.info.pre.switch : arbor.hooks.info.change_branch

---@alias arbor.hooks.pre.switch
---| function(info: arbor.hooks.info.pre.switch): arbor.hooks.info.pre.switch

---@class arbor.hooks.info.post.switch : arbor.hooks.info.post
---@class arbor.hooks.info.post.switch : arbor.hooks.info.change_path
---@class arbor.hooks.info.post.switch : arbor.hooks.info.change_branch

---@alias arbor.hooks.post.switch
---| function(info: arbor.hooks.info.post.switch): arbor.hooks.info.post.switch

-- MOVE

---@class arbor.hooks.info.pre.move : arbor.hooks.info.pre
---@class arbor.hooks.info.pre.move : arbor.hooks.info.change_path

---@alias arbor.hooks.pre.move
---| function(info: arbor.hooks.info.pre.move): arbor.hooks.info.pre.move

---@class arbor.hooks.info.post.move : arbor.hooks.info.post
---@class arbor.hooks.info.post.move : arbor.hooks.info.change_path

---@alias arbor.hooks.post.move: arbor.hooks.info.pre.switch
---| function(info: arbor.hooks.info.post.move): arbor.hooks.info.post.move
