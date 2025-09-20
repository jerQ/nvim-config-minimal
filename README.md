# nvim-config-minimal


Super simple, easy to understand, one file minimalist config for NVIM. 
This is a good starting point for your own modifications.


**Keybindings**

    Normal: ff — Open Telescope file picker (Telescope find_files)
    Normal: fg — Live grep with Telescope (Telescope live_grep)
    Normal: fb — List open buffers in Telescope (Telescope buffers)
    Normal: fh — Search help tags with Telescope (Telescope help_tags)
    Normal: gs — Toggle GitSigns inline signs (Gitsigns toggle_signs)
    Normal: q — Quit current window (:q)
    Normal: w — Save current buffer (:w)

LSP buffer-local mappings (set when LSP attaches):

    Normal: gd — Go to symbol definition (vim.lsp.buf.definition)
    Normal: gr — List references for symbol (vim.lsp.buf.references)
    Normal: gi — Go to implementation(s) (vim.lsp.buf.implementation)
    Normal: K — Show hover documentation (vim.lsp.buf.hover)
    Normal: rn — Rename symbol (vim.lsp.buf.rename)
    Normal: ca — Show code actions (vim.lsp.buf.code_action)
    Normal: f — Format file asynchronously via LSP (vim.lsp.buf.format)

nvim-cmp completion mappings (insert/select modes):

    Insert/Select: — Scroll completion docs up
    Insert/Select: — Scroll completion docs down
    Insert/Select: — Trigger completion menu
    Insert/Select: — Confirm selected completion (selects first if none)
    Insert/Select: — If completion visible: select next item; elseif snippet expandable/jumpable: expand/jump; else fallback
    Insert/Select: — If completion visible: select previous item; elseif snippet jumpable backward: jump; else fallback

DAP (if dap loaded) normal-mode mappings:

    Normal: — DAP: continue / start debugging
    Normal: — DAP: step over
    Normal: — DAP: step into
    Normal: — DAP: step out
    Normal: db — Toggle breakpoint
    Normal: dr — Open DAP REPL

