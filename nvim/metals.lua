local metals_config = require("metals").bare_config()
local metals_executable_path = vim.g.metals_executable_path
metals_config.init_options.statusBarProvider = "off"
metals_config.settings = {
  metalsBinaryPath = metals_executable_path
}

metals_config.on_attach = function(client, bufnr)
  require("metals").setup_dap()
end


local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})
