local Job = require("plenary.job")
local M = {}

M.generate = function(cfg, lang, tag_file, filepath)
  local args = {
    "-f",
    tag_file:expand(),
  }
  for _, v in ipairs(cfg.args) do
    table.insert(args, v)
  end

  if lang then
    table.insert(args, "--languages=" .. lang)
  end
  if filepath then
    table.insert(args, "-a")
    table.insert(args, filepath)
  else
    table.insert(args, "-R")
    table.insert(args, cfg.root_dir:expand())
  end

  if cfg.debug then
    vim.print(cfg.bin .. ' ' .. vim.inspect(args))
  end

  local j = Job:new({
    command = cfg.bin,
    args = args,
    on_exit = vim.schedule_wrap(function(job, code)
      if code ~= 0 then
        vim.print(job._stderr_results)
      end
    end),
  })

  if cfg.async then
    j:start()
  else
    j:sync()
  end
end

return M
