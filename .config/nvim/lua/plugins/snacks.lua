-- Customize Snacks

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        list = {
          keys = {
            ["<CR>"] = { "edit_vsplit", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
