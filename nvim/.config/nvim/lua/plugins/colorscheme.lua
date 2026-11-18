return {
  -- Everforest colorscheme
  -- {
  --   'sainnhe/everforest',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.everforest_background = 'medium'
  --     vim.g.everforest_enable_italic = true
  --     vim.cmd.colorscheme('everforest')
  --   end
  -- },

  -- lua/plugins/rose-pine.lua
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        styles = {
          transparency = true,
        },
        highlight_groups = {
          TelescopeBorder = { fg = "highlight_high", bg = "none" },
          TelescopeNormal = { bg = "none" },
          TelescopePromptNormal = { bg = "base" },
          TelescopeResultsNormal = { fg = "subtle", bg = "none" },
          TelescopeSelection = { fg = "text", bg = "base" },
          TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
        },
      })
      vim.cmd("colorscheme rose-pine")
    end
  },
  
  -- Auto dark mode integration
  {
    "f-person/auto-dark-mode.nvim",
    config = function()
      if vim.uv.os_uname().sysname == "Darwin" then
        local interval = require("auto-dark-mode.interval")
        local start = interval.start
        interval.start = function(options, state)
          state.query_command = {
            "sh", "-c",
            [[[ "$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')" = true ] && echo Dark]],
          }
          start(options, state)
        end
      end
      require("auto-dark-mode").setup({})
    end,
  },
}
