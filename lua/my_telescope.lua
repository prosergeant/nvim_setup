local action_state = require("telescope.actions.state")

local M = {}

-- Универсальная функция удаления
M.smart_delete = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local picker_name = current_picker.prompt_title:lower() -- Узнаем, где мы находимся

    current_picker:delete_selection(function(selection)
        -- 1. Если мы в БУФЕРАХ
        if picker_name:find("buffers") then
            if selection.bufnr and vim.api.nvim_buf_is_valid(selection.bufnr) then
                vim.api.nvim_buf_delete(selection.bufnr, { force = true })
            end

        -- 2. Если мы в ВЕТКАХ ГИТА
        elseif picker_name:find("git branches") then
            local branch = selection.value
            -- Удаляем ветку через системную команду
            vim.fn.system("git branch -D " .. branch)
            print("Ветка " .. branch .. " удалена")
        end
    end)
end

M.setup = function()
    require('telescope').setup{
      defaults = {
        mappings = {
          i = { ["<C-d>"] = M.smart_delete },
          n = { ["dd"] = M.smart_delete },
        },
      },
    }
end

return M
