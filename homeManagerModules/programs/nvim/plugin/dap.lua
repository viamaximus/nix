local dap = require("dap")
local dapui = require("dapui")

require("mason").setup()
require("mason-nvim-dap").setup({
  automatic_installation = false,
  handlers = {},
})

require("nvim-dap-virtual-text").setup({})

dapui.setup({})

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

local lldb_command = nil
if vim.fn.executable("lldb-dap") == 1 then
  lldb_command = "lldb-dap"
elseif vim.fn.executable("lldb-vscode") == 1 then
  lldb_command = "lldb-vscode"
else
  vim.notify("No LLDB DAP adapter found on PATH (tried lldb-dap and lldb-vscode)", vim.log.levels.ERROR)
end

dap.adapters.lldb = {
  type = "executable",
  command = lldb_command,
  name = "lldb",
}

local c_like = {
  {
    name = "Launch current executable",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = function()
      local input = vim.fn.input("Program arguments: ")
      return vim.split(input, " ", { trimempty = true })
    end,
    runInTerminal = false,
  },
}

dap.configurations.c = c_like
dap.configurations.cpp = c_like
