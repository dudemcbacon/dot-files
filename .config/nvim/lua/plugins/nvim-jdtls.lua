---@type LazySpec
return {
  "mfussenegger/nvim-jdtls",
  opts = {
    init_options = {
      settings = {
        java = {
          imports = {
            gradle = {
              wrapper = {
                checksums = {
                  { sha256 = "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172", allowed = true },
                },
              },
            },
          },
        },
      },
    },
    settings = {
      java = {
        saveActions = {
          organizeImports = true,
        },
      },
    },
  },
}
