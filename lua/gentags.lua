local ctags = require("gentags.ctags")
local Path = require("plenary.path")

local M = {}
local config = {
  autostart = true,
  append_on_save = true,
  root_dir = vim.g.gentags_root_dir or vim.loop.cwd(),
  cache = {
    path = Path:new(vim.fn.stdpath("cache")):joinpath("tags"),
  },
  async = true,
  bin = "ctags",
  args = {
    "--extras=+r+q",
    "--exclude=.git",
    "--exclude=node_modules*",
    "--exclude=.mypy*",
    "--exclude=.pytest*",
    "--exclude=.ruff*",
    "--exclude=BUILD",
    "--exclude=vendor*",
    "--exclude=*.min.*",
  },
  -- generate filetype based tag
  lang_ft_map = {
    ["Python"] = { "python" },
    ["Lua"] = { "lua" },
    ["Vim"] = { "vim" },
    ["C,C++,CUDA"] = { "c", "cpp", "h", "cuda" },
    ["JavaScript"] = { "javascript" },
    ["Go"] = { "go" },
    ["Rust"] = { "rust" },
    ["Markdown"] = { "markdown" },
    ["Make"] = { "make" },
  },

  debug = false,

  -- autogenerated
  lang_tag_map = {},

  -- one tags file to rule them all
  single_tags_file = nil,
}

local au_group = vim.api.nvim_create_augroup("GenTags", { clear = true })

M.generate = function()
  local lang = nil
  local ft = vim.bo.filetype

  for key, fts in pairs(config.lang_ft_map) do
    for _, _ft in ipairs(fts) do
      if ft == _ft then
        lang = key
        break
      end
    end
  end
  if config.single_tags_file then
    ctags.generate(config, nil, config.single_tags_file, nil)
  elseif lang then
    ctags.generate(config, lang, config.lang_tag_map[lang], nil)
  end
end

M.enable = function()

  if config.single_tags_file and config.debug then
    vim.print('[gentags.enable] single_tags_file=', config.single_tags_file.filename)
  end

  if config.single_tags_file ~= nil then
    vim.cmd('set tags=' .. config.single_tags_file:expand())
  end

  for lang, lang_tag_file in pairs(config.lang_tag_map) do
    local ft = config.lang_ft_map[lang]
    local tag_file = (
      config.single_tags_file
      or lang_tag_file
    )

    -- init file
    vim.api.nvim_create_autocmd({ "FileType" }, {
      group = au_group,
      pattern = ft,
      once = true,
      callback = function()
        if tag_file:exists() then
          return
        end
        ctags.generate(config, lang, tag_file, nil)
      end,
    })

    -- buffer append generated tagfile
    vim.api.nvim_create_autocmd({ "FileType" }, {
      group = au_group,
      pattern = ft,
      callback = function(args)
        if config.single_tags_file == null then
          vim.cmd("setlocal tags+=" .. lang_tag_file:expand())
        end

        -- append new tags to file
        vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
          group = au_group,
          buffer = args.buf,
          callback = function()
            local filepath = vim.fn.expand("%:p")
            ctags.generate(config, lang, tag_file, filepath)
          end,
        })
      end,
    })
  end
end

M.disable = function()
  if au_group ~= nil then
    vim.api.nvim_del_augroup_by_id(au_group)
    au_group = vim.api.nvim_create_augroup("GenTags", { clear = true })
  end
end

M.setup = function(args)
  if args == nil then
    args = {}
  end
  if args.single_tags_file then
    args.single_tags_file = Path:new(args.single_tags_file)
  end
  config = vim.tbl_deep_extend("keep", args, config)

  local root_path = Path:new(config.root_dir)
  config.root_dir = root_path
  Path:new(config.cache.path):mkdir({ exists_ok = true })

  config.cache.path = Path:new(config.cache.path)

  for lang_name, _ in pairs(config.lang_ft_map) do
    local tag_file = lang_name:gsub(",", "_") .. root_path:shorten():gsub(root_path._sep, "_"):gsub("%.", "")
    config.lang_tag_map[lang_name] = config.cache.path:joinpath(tag_file)
  end

  if config.autostart then
    M.enable()
  end
end

return M
