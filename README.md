# Auto generate tag files by ctags

This plugin autogenerates tags into single `tags` file
Fork of [JMarkin/gentags.lua](https://github.com/JMarkin/gentags.lua)
Better use [linrongbin16/gentags.nvim](https://github.com/linrongbin16/gentags.nvim)


## Install

```lua
{
    "JMarkin/gentags.lua",
    cond = vim.fn.executable("ctags") == 1,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    opts = {}
}
```

## Configuration

```lua
{
  autostart = true,
  root_dir = vim.g.gentags_root_dir or vim.loop.cwd(),
  cache = {
    path = Path:new(vim.fn.stdpath("cache")):joinpath("tags"), -- path where generated tags store, currently required plenary Path object
  },
  debug = false, -- enables extra logging
  single_tags_file = vim.g.ctags_cache_file,  -- TODO: move into `.cache` opt
  async = true, -- run ctags asynchronous
  bin = "ctags",
  args = { -- extra args
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
  -- mapping ctags --languages <-> neovim filetypes
  lang_ft_map = {
    ["Python"] = { "python" },
    ["Lua"] = { "lua" },
    ["Vim"] = { "vim" },
    ["C,C++,CUDA"] = { "c", "cpp", "h", "cuda" },
    ["JavaScript"] = { "javascript" },
    ["Go"] = { "go" },
  }
}
```
