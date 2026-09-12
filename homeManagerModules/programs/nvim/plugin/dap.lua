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

-- Resolve to an absolute path, not the bare name.
local lldb_command = nil
for _, candidate in ipairs({ "lldb-dap", "lldb-vscode" }) do
  local resolved = vim.fn.exepath(candidate)
  if resolved ~= "" then
    lldb_command = resolved
    break
  end
end

if not lldb_command then
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
dap.configurations.rust = c_like
