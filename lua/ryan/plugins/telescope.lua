return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")

		telescope.load_extension("fzf")

    local delete_buffer = function(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      actions.close(prompt_bufnr) -- close Telescope window

      if entry and entry.bufnr then
        vim.api.nvim_buf_delete(entry.bufnr, { force = true })
      end

      -- slight delay to allow buffer delete to register before reopening
      vim.defer_fn(function()
        builtin.buffers()
        vim.defer_fn(function()
          vim.cmd("stopinsert")
        end, 20)
      end, 50)
    end

    telescope.setup({
        defaults = {
            mappings = {
                i = {
                    ["<c-d>"] = delete_buffer, -- insert mode
                },
                n = {
                    ["dd"] = delete_buffer, -- normal mode
                },
            },
        },
        pickers = {
            buffers = {
                sort_lastused = true,
                mappings = {
                    i = {
                        ["<c-d>"] = delete_buffer,
                    },
                    n = {
                        ["<c-d>"] = delete_buffer,
                    },
                },
            },
        },
    })

		local keymap = vim.keymap

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr><esc>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr><esc>", { desc = "Fuzzy find buffers" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr><esc>", { desc = "Find todos" })
	end,
}
