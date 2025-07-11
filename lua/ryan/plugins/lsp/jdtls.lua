return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
  },
  config = function()
    require("mason").setup() -- must call mason.setup once
    require("mason-registry").refresh(function()
      local registry = require("mason-registry")

      if not registry.has_package("jdtls") then
        vim.notify("jdtls not found in mason-registry", vim.log.levels.ERROR)
        return
      end

      local jdtls_pkg = registry.get_package("jdtls")
      if not jdtls_pkg:is_installed() then
        vim.notify("jdtls is not installed. Run :MasonInstall jdtls", vim.log.levels.ERROR)
        return
      end

      local jdtls = require("jdtls")
      local home = os.getenv("HOME")
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

      local root_markers = { ".git", "pom.xml", "brazil.cfg", ".brazil", "build.xml" }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      if not root_dir then
        vim.notify("JDTLS: Could not find project root", vim.log.levels.WARN)
        return
      end

      local jdtls_path = jdtls_pkg:get_install_path()
      local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      local config_path = jdtls_path .. "/config_linux"

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", launcher_jar,
          "-configuration", config_path,
          "-data", workspace_dir,
        },
        root_dir = root_dir,
      }

      jdtls.start_or_attach(config)
    end)
  end,
}

