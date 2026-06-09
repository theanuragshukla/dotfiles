require("gemini").setup({
  win = {
    preset = "floating",  -- Options: "right-fixed", "left-fixed", "bottom-fixed", "floating"
    -- width = 0.8,
    -- height = 0.8,
  }
})

require("copilot").setup({
	suggestion = { enabled = true },
	panel = { enabled = true },
})

