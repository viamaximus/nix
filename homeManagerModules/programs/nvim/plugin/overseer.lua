-- ---------------------------------------------------------------------------
-- overseer: run arbitrary cargo tasks with output in a split
-- ---------------------------------------------------------------------------
local ok, overseer = pcall(require, "overseer")
if not ok then
  return
end

overseer.setup({
  task_list = {
    direction = "bottom",
    min_height = 12,
    bindings = { ["q"] = "<Cmd>close<CR>" },
  },
})

-- A few cargo tasks worth having one keystroke away. `cargo run` gets a
-- terminal strategy so interactive programs still read stdin.
local cargo_tasks = {
  { name = "cargo check", args = { "check", "--all-targets" } },
  { name = "cargo clippy", args = { "clippy", "--all-targets", "--", "-D", "warnings" } },
  { name = "cargo test", args = { "nextest", "run" } },
  { name = "cargo build --release", args = { "build", "--release" } },
  { name = "cargo bench", args = { "criterion" } },
  { name = "cargo machete", args = { "machete" } },
  { name = "cargo audit", args = { "audit" } },
  { name = "cargo deny", args = { "deny", "check" } },
  { name = "cargo doc --open", args = { "doc", "--no-deps", "--open" } },
}

-- Keymaps live in initLua (mapleader is not set yet when this file runs).
vim.api.nvim_create_user_command("CargoTask", function()
  vim.ui.select(cargo_tasks, {
    prompt = "cargo task",
    format_item = function(item) return item.name end,
  }, function(choice)
    if not choice then
      return
    end
    local task = overseer.new_task({
      cmd = { "cargo" },
      args = choice.args,
      name = choice.name,
      components = { "default" },
    })
    task:start()
    overseer.open({ enter = false })
  end)
end, { desc = "Pick and run a cargo task" })
