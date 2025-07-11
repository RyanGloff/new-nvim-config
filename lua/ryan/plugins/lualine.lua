return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")

    local get_active_lsp = function()
      local msg = "No Active Lsp"
      local buf_ft = vim.api.nvim_get_option_value("filetype", {})
      local clients = vim.lsp.get_clients { bufnr = 0 }
      if next(clients) == nil then
        return msg
      end

      for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
          return client.name
        end
      end
      return msg
    end

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = "auto",
      },
      sections = {
        lualine_c = {
          {
            get_active_lsp,
            icon = " LSP:",
          },
        },
        lualine_x = {
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}
