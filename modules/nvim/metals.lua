local metals_config = require("metals").bare_config()
local metals_executable_path = vim.g.metals_executable_path
metals_config.init_options.statusBarProvider = "off"
metals_config.settings = {
  metalsBinaryPath = metals_executable_path
}

require("metals").setup_dap()


local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})
metals_config.on_attach = function(client, bufnr)
  -- Add error handling when setting up DAP
  local status_ok, _ = pcall(require("metals").setup_dap)
  if not status_ok then
    vim.notify("Error setting up Metals DAP", vim.log.levels.WARN)
  end
end
