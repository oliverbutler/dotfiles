-- terraformls - Terraform Language Server
-- Provides Terraform/HCL language support

---@type vim.lsp.Config
return {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform", "terraform-vars", "hcl" },
	root_markers = {
		".terraform",
		".git",
		"terraform.tfvars",
	},
}
