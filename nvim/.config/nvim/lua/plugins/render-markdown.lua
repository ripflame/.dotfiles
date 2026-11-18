return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
		config = function()
			local win = require("render-markdown.lib.env").win
			local win_width = win.width
			win.width = function(id)
				local width = win_width(id)
				local cc = tonumber(vim.wo[id].colorcolumn:match("^%d+"))
				return cc and math.min(width, cc - 1) or width
			end

			require("render-markdown").setup({
				code = {
					language_border = " ",
					highlight = "RenderMarkdownCode",
				},
				render_modes = { "n", "c", "t" },
				pipe_table = { cell = "trimmed" },
				completions = { lsp = { enabled = true } },
				win_options = { wrap = { default = true, rendered = true } },
				anti_conceal = { enabled = false },
			})
		end,
	},
}
