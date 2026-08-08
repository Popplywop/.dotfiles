---@brief
---
--- https://github.com/microsoft/typescript-go
---
--- `tsgo` is the experimental Go port of the TypeScript compiler/language
--- server. Install with `npm install -g @typescript/native-preview`.
---
--- Supports monorepos out of the box: it finds the tsconfig.json/jsconfig.json
--- for whatever package you're editing without spawning multiple instances.

---@type vim.lsp.Config
return {
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
		},
	},
	cmd = function(dispatchers, config)
		local cmd = "tsgo"
		if (config or {}).root_dir then
			local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
			if vim.fn.executable(local_cmd) == 1 then
				cmd = local_cmd
			end
		end
		return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
	end,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function(bufnr, on_dir)
		local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
		root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
			or vim.list_extend(root_markers, { ".git" })

		local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
		local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
		local project_root = vim.fs.root(bufnr, root_markers)
		if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
			return -- deno lock is closer than package manager lock, abort
		end
		if deno_root and (not project_root or #deno_root >= #project_root) then
			return -- deno config is closer than or equal to package manager lock, abort
		end
		on_dir(project_root or vim.fn.getcwd())
	end,
}
