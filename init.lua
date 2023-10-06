return {
  -- Configure AstroNvim updates
  updater = {
    remote = "origin",     -- remote to use
    channel = "stable",    -- "stable" or "nightly"
    version = "latest",    -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "nightly",    -- branch name (NIGHTLY ONLY)
    commit = nil,          -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil,     -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false,  -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_quit = false,     -- automatically quit the current session after a successful update
    remotes = {            -- easily add new remotes to track
      --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
      --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
      --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    },
  },

  -- Set colorscheme to use
  colorscheme = "astrolight",

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true,     -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          "html",
          "scss",
          "ts",
          "tsx",
          "js",
          "jsx"
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
          --
        },
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    config = {
      tsserver = {
        init_options = {
          preferences = {
            importModuleSpecifierPreference = 'relative',
            importModuleSpecifierEnding = 'minimal'
          }
        }
      }
    }
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }
    --
    -- formatting i don't need it :(
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   pattern = { "*.ts", "*.tsx" },
    --   callback = function()
    --     vim.lsp.buf.format({ timeout = 3000 })
    --   end
    -- })
--

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.ts", "*.tsx" },
      callback = function()
        local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding(0))
        -- https://microsoft.github.io/language-server-protocol/specifications/specification-3-15/#codeActionContext
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }

        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        for _, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding(0))
            else
              vim.lsp.buf.execute_command(r.command)
            end
          end
        end
        -- vim.lsp.buf.format()
      end
    })

  end,
}
