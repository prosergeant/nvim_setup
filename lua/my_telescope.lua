local action_state = require("telescope.actions.state")

local M = {}


M.smart_checkout = function(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if not selection then return end

  -- Очищаем имя ветки от 'origin/' если оно там есть
  local branch = selection.value:gsub("^origin/", "")
  require("telescope.actions").close(prompt_bufnr)

  -- 1. Переключаемся
  vim.fn.system("git checkout " .. branch)

  -- 2. Проверяем наличие связи с удаленной веткой
  local upstream_check = vim.fn.system("git rev-parse --abbrev-ref " .. branch .. "@{u} 2>&1")

  -- Если в ответе есть 'fatal', значит связи нет
  if upstream_check:match("fatal") then
    -- 3. Принудительно связываем с origin
    local set_out = vim.fn.system("git branch --set-upstream-to=origin/" .. branch .. " " .. branch)

    if set_out:match("error") then
      print("❌ Не удалось связать: ветки origin/" .. branch .. " не существует")
    else
      print("✅ Связь с origin/" .. branch .. " установлена")
    end
  else
    print("🌍 Ветка " .. branch .. " уже связана")
  end

  -- Перегружаем буферы, чтобы изменения применились в UI
  vim.cmd("checktime")
end

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
  require('telescope').setup {
    defaults = {
      mappings = {
        i = { ["<C-d>"] = M.smart_delete },
        n = { ["dd"] = M.smart_delete },
      },
    },
    pickers = {
      git_branches = {
        mappings = {
          -- Переопределяем Enter только для веток гита
          i = { ["<CR>"] = M.smart_checkout },
          n = { ["<CR>"] = M.smart_checkout },
        }
      }
    }
  }
end

return M
