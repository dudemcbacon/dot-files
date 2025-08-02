---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        "graphql", -- required for graphql-lsp
      },
    },
  },
}
