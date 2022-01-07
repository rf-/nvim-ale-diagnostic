local ale_diagnostic_severity_map = {
  [vim.lsp.protocol.DiagnosticSeverity.Error] = "E";
  [vim.lsp.protocol.DiagnosticSeverity.Warning] = "W";
  [vim.lsp.protocol.DiagnosticSeverity.Information] = "I";
  [vim.lsp.protocol.DiagnosticSeverity.Hint] = "I";
}

vim.diagnostic.original_reset = vim.diagnostic.reset
vim.diagnostic.reset = function(namespace, bufnr)
  vim.diagnostic.original_reset(namespace, bufnr)

  -- Clear ALE
  vim.api.nvim_call_function('ale#other_source#ShowResults', {bufnr, "nvim-lsp", {}})
  vim.b[bufnr].prev_nvim_lsp_diagnostics = nil
end

function vim.diagnostic.show(namespace, bufnr, ...)
  -- Get all diagnostics from the current buffer
  local diagnostics = vim.diagnostic.get(bufnr)
  local items = {}

  for _, item in ipairs(diagnostics) do
    local nr = ''
    if item.user_data and item.user_data.lsp and item.user_data.lsp.code then
      nr = item.user_data.lsp.code
    end
    table.insert(items, {
      nr = nr,
      text = item.message,
      lnum = item.lnum+1,
      end_lnum = item.end_lnum,
      col = item.col+1,
      end_col = item.end_col,
      type = ale_diagnostic_severity_map[item.severity]
    })
  end

  -- Only call `ShowResults` if the diagnostics have actually changed
  if not vim.deep_equal(vim.b[bufnr].prev_nvim_lsp_diagnostics, items) then
    vim.api.nvim_call_function(
      'ale#other_source#ShowResults',
      {bufnr, "nvim-lsp", items}
    )
    vim.b[bufnr].prev_nvim_lsp_diagnostics = items
  end
end
