return {
    "seblyng/roslyn.nvim",
    ft = "cs",
    dependencies = {
        "mason-org/mason.nvim",
    },
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
        -- Auto-install the Roslyn language server via Mason
        mason = true,
        config = {
            settings = {
                ["csharp|code_lens"] = {
                    dotnet_enable_references_code_lens = false,
                },
            },
        },
    },
}