-- local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- Выносим функцию удаления отдельно
M.delete_buf = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:delete_selection(function(selection)
        vim.api.nvim_buf_delete(selection.bufnr, { force = true })
    end)
end

-- Настройка самого Telescope
M.setup = function()
    require('telescope').setup{
      defaults = {
        mappings = {
          i = { ["<C-d>"] = M.delete_buf },
          n = { ["dd"] = M.delete_buf },
        },
      },
    }
end

return M
