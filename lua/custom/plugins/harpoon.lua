return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('harpoon'):setup()
  end,
  keys = function()
    local harpoon = require 'harpoon'

    local conf = require('telescope.config').values

    local function toggle_telescope(harpoon_files)
      local file_paths = {}

      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      local make_finder = function()
        local paths = {}

        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end

        return require('telescope.finders').new_table {
          results = paths,
        }
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = false,
          sorter = conf.generic_sorter {},
          layout_strategy = 'center',
          layout_config = {
            preview_cutoff = 1, -- Preview should always show (unless previewer = false)

            width = function(_, max_columns, _)
              return math.min(max_columns, 80)
            end,

            height = function(_, _, max_lines)
              return math.min(max_lines, 15)
            end,
          },
          borderchars = {
            prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
            results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
            preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
          },
          attach_mappings = function(prompt_buffer_number, map)
            map('i', '<c-d>', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_buffer_number)

              harpoon:list():remove(selected_entry)
              current_picker:refresh(make_finder())
            end)

            return true
          end,
        })
        :find()
    end

    return {
      {
        '<leader>ft',
        function()
          toggle_telescope(harpoon:list())
        end,
        desc = 'Harpoon [T]elescope View',
      },
      {
        '<leader>fh',
        function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = '[H]arpoon Default View',
      },
      {
        '<leader>fa',
        function()
          harpoon:list():add()
        end,
        desc = 'Harpoon [A]dd file',
      },
      {
        '<leader>fd',
        function()
          local idx = vim.fn.line '.'
          while idx < harpoon:list():length() do
            local next_item = harpoon:list():get(idx + 1)
            harpoon:list():replace_at(idx, next_item)
            idx = idx + 1
          end
          harpoon:list():remove_at(idx)
          harpoon.ui:close_menu()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon [D]elete file',
      },

      -- Toggle previous & next buffers stored within Harpoon list
      {
        '<C-S-P>',
        function()
          harpoon:list():prev()
        end,
      },
      {
        '<C-S-N>',
        function()
          harpoon:list():next()
        end,
      },
    }
  end,
}
