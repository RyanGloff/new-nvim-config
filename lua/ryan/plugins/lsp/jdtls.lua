return {
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
    ft = { "java" },
    config = function()
      local mason_registry = require("mason-registry")
      local jdtls = require("jdtls")

      local function setup_jdtls()
        local home = os.getenv("HOME")
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

        local root_markers = { ".git", "pom.xml", "mvnw", "build.gradle", "gradlew" }
        local root_dir = require("jdtls.setup").find_root(root_markers)
        if not root_dir then return end

        local jdtls_pkg = mason_registry.get_package("jdtls")
        local jdtls_path = jdtls_pkg:get_install_path()
        local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local config_path = jdtls_path .. "/config_linux" -- or config_mac/config_win based on OS

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
          settings = {
            java = {
              configuration = {
                updateBuildConfiguration = "interactive",
              },
            },
          },
          init_options = {
            bundles = {},
          },
        }

        jdtls.start_or_attach(config)
      end

      -- Refresh mason registry if jdtls isn't ready yet
      if not mason_registry.has_package("jdtls") then
        mason_registry.refresh(function()
          if mason_registry.has_package("jdtls") then
            setup_jdtls()
          else
            vim.notify("JDTLS not found in Mason registry after refresh", vim.log.levels.ERROR)
          end
        end)
      else
        setup_jdtls()
      end
    end,
  },
}

