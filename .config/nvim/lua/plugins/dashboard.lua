return {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        config = function()
                local db = require("dashboard")

                function open_dot_files()
                        vim.cmd("e ~/.config/nvim")
                        vim.cmd("Telescope find_files")
                end

                function open_vault()
                        vim.cmd("e ~/vault")
                        vim.cmd("Telescope find_files")
                end

                db.setup({
                        theme = "doom",
                        shortcut_type = "number",
                        hide = {
                                statusline = false,
                                tabline = false,
                                winbar = false,
                        },
                        config = {
                                week_header = {
                                        enable = true,
                                },
                                center = {
                                        {
                                                desc = vim.fn.getcwd(),
                                        },
                                        {
                                                icon = "📂 ",
                                                icon_hl = "Title",
                                                desc = "Projects",
                                                desc_hl = "String",
                                                key = "p",
                                                key_hl = "Number",
                                                key_format = " %s",
                                                action = "lua require('telescope').extensions.project.project{}",
                                        },
                                        {
                                                icon = "📦 ",
                                                icon_hl = "Title",
                                                desc = "Open Dot Files",
                                                desc_hl = "String",
                                                key = "b",
                                                key_hl = "Number",
                                                key_format = " %s",
                                                action = "lua open_dot_files()",
                                        },
                                        {
                                                icon = "🔒 ",
                                                icon_hl = "Title",
                                                desc = "Open Vault",
                                                desc_hl = "String",
                                                key = "v",
                                                key_hl = "Number",
                                                key_format = " %s",
                                                action = "lua open_vault()",
                                        },
                                },
                        },
                        footer = {
                        },
                })
        end,
}
