return {
  "olimorris/codecompanion.nvim",
  init = function()
    vim.cmd([[cab cc CodeCompanion]])
    require("plugins.codecompanion.codecompanion-notifier"):init()

    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionInlineFinished",
      group = group,
      callback = function(request)
        vim.lsp.buf.format({ bufnr = request.buf })
      end,
    })
  end,
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCmd",
  },
  -- <leader>a  → Claude Code (terminal agent, claudecode.nvim)
  -- <leader>ai → CodeCompanion (inline chat panel, este plugin)
  keys = {
    { "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat Panel" },
    { "<leader>aI", "<cmd>CodeCompanionChat<cr>",        mode = { "n", "v" }, desc = "AI New Chat" },
    { "<leader>ae", "<cmd>CodeCompanion /explain<cr>",   mode = { "v" },       desc = "AI Explain" },
    {
      "<leader>gm",
      function()
        local buf_path = vim.api.nvim_buf_get_name(0)
        local buf_dir  = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":h") or vim.fn.getcwd()
        local git_root = vim.fn.system("git -C " .. vim.fn.shellescape(buf_dir) .. " rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
        local base     = git_root ~= "" and git_root or buf_dir

        local diff = vim.fn.system("git -C " .. vim.fn.shellescape(base) .. " diff --staged")
        if vim.trim(diff) == "" then
          diff = vim.fn.system("git -C " .. vim.fn.shellescape(base) .. " diff")
        end
        if vim.trim(diff) == "" then
          vim.notify("No hay cambios en el repo", vim.log.levels.WARN)
          return
        end

        local prompt = "Generá un mensaje de commit en formato Conventional Commits.\n"
          .. "Solo el mensaje (tipo(scope): descripción breve), sin explicaciones extra. En español.\n\n"
          .. "```diff\n" .. diff .. "\n```"

        require("codecompanion.strategies.chat").new({
          context = {
            bufnr    = vim.api.nvim_get_current_buf(),
            cursor_pos = vim.api.nvim_win_get_cursor(0),
            mode     = "n",
            winnr    = vim.api.nvim_get_current_win(),
            filetype = vim.bo.filetype,
            filename = vim.api.nvim_buf_get_name(0),
            is_visual = false,
          },
          messages     = { { role = "user", content = prompt } },
          auto_submit  = true,
        })
      end,
      desc = "AI Commit message",
    },
    { "ga",         "<cmd>CodeCompanionChat Add<CR>",    mode = { "v" },       desc = "AI Add to Chat" },
  },
  opts = function()
    local prompt = require("config.gentleman_prompt")
    return {
      system_prompt = prompt.system_prompt,
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-sonnet-4-5",
              },
            },
          })
        end,
      },
      display = {
        diff = {
          enabled = true,
          layout = "vertical",
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "default",
        },
        chat = {
          window = {
            position = "right",
            width = 0.30,
          },
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          slash_commands = {
            ["git_files"] = {
              description = "List git files",
              callback = function(chat)
                local handle = io.popen("git ls-files")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()
                  chat:add_reference({ role = "user", content = result }, "git", "<git_files>")
                else
                  vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = { contains_code = false },
            },
          },
          keymaps = {
            send  = { modes = { n = "<CR>",  i = "<C-s>" } },
            close = { modes = { n = "<C-c>", i = "<C-c>" } },
          },
          roles = {
            llm  = function(adapter) return "Claude (" .. adapter.formatted_name .. ")" end,
            user = "Vos",
          },
          tools = {
            ["cmd_runner"] = {
              callback    = "strategies.chat.agents.tools.cmd_runner",
              description = "Run shell commands initiated by the LLM",
              opts        = { requires_approval = true },
            },
            ["editor"] = {
              callback    = "strategies.chat.agents.tools.editor",
              description = "Update a buffer with the LLM's response",
            },
            ["files"] = {
              callback    = "strategies.chat.agents.tools.files",
              description = "Update the file system with the LLM's response",
              opts        = { requires_approval = true },
            },
          },
        },
        inline = {
          adapter = "copilot",
          keymaps = {
            accept_change = { modes = { n = "ga" }, description = "Accept the suggested change" },
            reject_change = { modes = { n = "gr" }, description = "Reject the suggested change" },
          },
        },
      },
    }
  end,
}
