-- ftplugin/java.lua
-- Only load this for Java files
if vim.bo.filetype ~= 'java' then
  return
end

-- Check if jdtls is installed
local jdtls_ok, jdtls = pcall(require, 'jdtls')
if not jdtls_ok then
  vim.notify('nvim-jdtls not installed. Run :Lazy sync', vim.log.levels.ERROR)
  return
end

-- Find project root
local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'settings.gradle', 'settings.gradle.kts', 'build.gradle.kts' }
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  vim.notify('No Java project root found', vim.log.levels.WARN)
  return
end

-- Setup paths
local home = os.getenv('HOME')
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = home .. '/.local/share/nvim/jdtls-workspace/' .. project_name

-- Mason installation path
local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

-- Check if jdtls is installed via Mason
if vim.fn.isdirectory(mason_path) == 0 then
  vim.notify('JDTLS not installed. Run :MasonInstall jdtls', vim.log.levels.ERROR)
  return
end

-- Platform-specific configuration
local config_dir = mason_path .. '/config_linux'
if vim.fn.has('mac') == 1 then
  config_dir = mason_path .. '/config_mac'
elseif vim.fn.has('win32') == 1 then
  config_dir = mason_path .. '/config_win'
end

-- Find the launcher JAR
local launcher_jar = vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
if launcher_jar == '' then
  vim.notify('JDTLS launcher jar not found', vim.log.levels.ERROR)
  return
end

-- Get capabilities for autocompletion
local cmp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if cmp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Explicitly enable semantic tokens
capabilities.textDocument.semanticTokens = {
  dynamicRegistration = false,
  requests = {
    range = true,
    full = {
      delta = true,
    },
  },
  tokenTypes = {
    "namespace", "type", "class", "enum", "interface", "struct", "typeParameter",
    "parameter", "variable", "property", "enumMember", "event", "function",
    "method", "macro", "keyword", "modifier", "comment", "string", "number",
    "regexp", "operator", "decorator",
  },
  tokenModifiers = {
    "declaration", "definition", "readonly", "static", "deprecated", "abstract",
    "async", "modification", "documentation", "defaultLibrary",
  },
  formats = { "relative" },
  overlappingTokenSupport = false,
  multilineTokenSupport = false,
}

-- Extended capabilities for JDTLS
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
extendedClientCapabilities.progressReportProvider = true
extendedClientCapabilities.classFileContentsSupport = true
extendedClientCapabilities.generateToStringPromptSupport = true
extendedClientCapabilities.hashCodeEqualsPromptSupport = true
extendedClientCapabilities.advancedExtractRefactoringSupport = true
extendedClientCapabilities.advancedOrganizeImportsSupport = true
extendedClientCapabilities.generateConstructorsPromptSupport = true
extendedClientCapabilities.generateDelegateMethodsPromptSupport = true
extendedClientCapabilities.moveRefactoringSupport = true
extendedClientCapabilities.overrideMethodsPromptSupport = true
extendedClientCapabilities.inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" }

-- JDTLS configuration
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx2g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher_jar,
    '-configuration', config_dir,
    '-data', workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
        updateSnapshots = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      semanticHighlighting = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      signatureHelp = {
        enabled = true,
        description = {
          enabled = true,
        },
      },
      contentProvider = { preferred = 'fernflower' },
      sources = {
        organizeImports = {
          starThreshold = 1,
          staticStarThreshold = 1,
        },
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.lwjgl.glfw.GLFW.*",
          "org.lwjgl.opengl.GL11.*",
          "org.lwjgl.opengl.GL20.*",
          "org.lwjgl.opengl.GL30.*",
          "org.lwjgl.opengl.GL33.*",
          "org.lwjgl.opengl.GL45.*",
          "org.lwjgl.vulkan.VK10.*",
          "org.lwjgl.system.MemoryUtil.*",
          "org.lwjgl.system.MemoryStack.*",
          "imgui.ImGui.*",
          "imgui.flag.ImGuiWindowFlags.*",
          "imgui.flag.ImGuiCol.*",
          "imgui.type.ImBoolean.*",
          "imgui.type.ImInt.*",
          "imgui.type.ImFloat.*",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "sun.*",
          "jdk.*",
        },
        importOrder = {
          "java",
          "javax",
          "org.lwjgl",
          "imgui",
          "org",
          "com",
        },
      },
      configuration = {
        detectJdksAtStart = true,
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = vim.fn.expand("~/.sdkman/candidates/java/8.0.432-tem"),
            default = false,
          },
          {
            name = "JavaSE-11",
            path = vim.fn.expand("~/.sdkman/candidates/java/11.0.25-tem"),
            default = false,
          },
          {
            name = "JavaSE-17",
            path = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-tem"),
            default = false,
          },
          {
            name = "JavaSE-21",
            path = vim.fn.expand("~/.sdkman/candidates/java/21.0.5-tem"),
            default = true,
          },
        },
        updateBuildConfiguration = "automatic",
      },
      inlayHints = {
        parameterNames = {
          enabled = "all",
        },
      },
      referenceCodeLens = {
        enabled = true,
      },
      saveActions = {
        organizeImports = true,
      },
      server = {
        launchMode = "Standard",
      },
      autobuild = {
        enabled = true,
      },
      project = {
        referencedLibraries = {
          "lib/**/*.jar",
          "${env:HOME}/.m2/repository/org/lwjgl/**/*.jar",
          "${env:HOME}/.m2/repository/io/github/spair/**/*.jar",
          "libs/joml/**/*.jar",
        },
      },
      templates = {
        fileHeader = {
          "/**",
          " * ${file_name}",
          " *",
          " * @author ${user}",
          " * @date ${date}",
          " */",
        },
        typeComment = {},
      },
      trace = {
        server = "off",
      },
      import = {
        gradle = {
          enabled = true,
          wrapper = {
            enabled = true,
          },
          version = nil,
          home = nil,
          java = {
            home = nil,
          },
          offline = {
            enabled = false,
          },
          arguments = nil,
          jvmArguments = nil,
          user = {
            home = nil,
          },
        },
        maven = {
          enabled = true,
          downloadSources = true,
          updateSnapshots = true,
        },
        exclusions = {
          "**/node_modules/**",
          "**/.metadata/**",
          "**/archetype-resources/**",
          "**/META-INF/maven/**",
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
      lombok = {
        enabled = false,
      },
    },
  },

  capabilities = capabilities,

  on_attach = function(client, bufnr)
    -- Debug: Check if semantic tokens are supported
    print("JDTLS capabilities:")
    print("semanticTokensProvider:", vim.inspect(client.server_capabilities.semanticTokensProvider))

    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.start(bufnr, client.id)
      print("Semantic tokens started for buffer", bufnr)

      -- Force a refresh after a short delay
      vim.defer_fn(function()
        vim.lsp.semantic_tokens.force_refresh(bufnr)
      end, 100)
    else
      print("WARNING: JDTLS does not support semantic tokens!")
    end
  end,

  init_options = {
    bundles = {},
    extendedClientCapabilities = vim.tbl_deep_extend("force", extendedClientCapabilities, {
      semanticTokensRefreshSupport = true,
    }),
  },

  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "single",
    }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "single",
    }),
  },

  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
}

-- Start JDTLS
jdtls.start_or_attach(config)
