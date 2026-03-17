-- LSP helper functions

local M = {}

-- Helper to strip markdown image syntax from a string
local function strip_images(str)
    if not str then return str end
    return str:gsub("!%[.-%]%(.-%)%s*", "")
end

-- Strip image links from completion documentation
-- Fixes texlab showing raw image URLs instead of text descriptions
function M.setup_clean_documentation()
    -- Override the markdown line converter to strip images before rendering
    local original_convert = vim.lsp.util.convert_input_to_markdown_lines
    vim.lsp.util.convert_input_to_markdown_lines = function(input, contents)
        if type(input) == "string" then
            input = strip_images(input)
        elseif type(input) == "table" then
            if input.value then
                input.value = strip_images(input.value)
            end
            if input.kind and type(input) == "table" then
                for i, line in ipairs(input) do
                    if type(line) == "string" then
                        input[i] = strip_images(line)
                    end
                end
            end
        end
        return original_convert(input, contents)
    end
end

return M
