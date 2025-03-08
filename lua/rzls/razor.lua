local M = {}

---@class razor.LanguageQueryParams
---@field position lsp.Position
---@field uri string

---@class razor.LanguageQueryResponse
---@field hostDocumentVersion integer
---@field kind razor.LanguageKind
---@field position lsp.Position
---@field positionIndex integer

---@class razor.MapToDocumentRangesParams
---@field razorDocumentUri string
---@field kind razor.LanguageKind
---@field projectedRanges lsp.Range[]

---@class razor.MapToDocumentRangesResponse
---@field hostDocumentVersion integer
---@field ranges lsp.Range[]

---@class razor.ProvideSemanticTokensParams
---@field correlationId string
---@field textDocument lsp.TextDocumentIdentifier
---@field ranges lsp.Range[]
---@field requiredHostDocumentVersion integer

---@class razor.ProvideSemanticTokensResponse
---@field tokens integer[]
---@field hostDocumentSyncVersion integer

---@class razor.DelegatedCompletionRange
---@field tokens integer[]
---@field hostDocumentSyncVersion integer

---@class razor.DelegatedCompletionParams
---@field identifier { textDocumentIdentifier: lsp.TextDocumentIdentifier, version: integer }
---@field projectedPosition lsp.Position
---@field projectedKind razor.LanguageKind
---@field context lsp.CompletionContext
---@field provisionalTextEdit lsp.TextEdit
---@field shouldIncludeSnippets boolean

---@class razor.DelegatedCompletionItemResolveParams
---@field identifier { textDocumentIdentifier: lsp.TextDocumentIdentifier, version: integer }
---@field completionItem lsp.CompletionItem
---@field originatingKind razor.LanguageKind

---@class razor.ProvideDynamicFileParams
---@field razorDocument lsp.TextDocumentIdentifier
---@field fullText boolean

---@class razor.ProvideDynamicFileResponse
---@field csharpDocument? lsp.TextDocumentIdentifier
---@field updates? razor.DynamicFileUpdate[]
---@field checksum string
---@field checksumAlgorithm number
---@field encodingCodePage number | vim.NIL

---@class razor.DynamicFileUpdate
---@field edits Change[]

---@class razor.DynamicFileUpdatedParams
---@field razorDocument lsp.TextDocumentIdentifier

---@class razor.DelegatedInlayHintParams
---@field identifier { textDocumentIdentifier: lsp.TextDocumentIdentifier, version: integer }
---@field projectedKind razor.LanguageKind
---@field projectedRange lsp.Range

---@class razor.DelegatedInlayHintResolveParams
---@field identifier { textDocumentIdentifier: lsp.TextDocumentIdentifier, version: integer }
---@field inlayHint lsp.InlayHint
---@field projectedKind razor.LanguageKind

---@enum razor.LanguageKind
M.language_kinds = {
    csharp = 1,
    html = 2,
    razor = 3,
}

---@enum (key) razor.VirtualSuffix
M.virtual_suffixes = {
    html = "__virtual.html",
    csharp = "__virtual.cs",
}

---@enum razor.LSPClientName
M.lsp_names = {
    [M.language_kinds.html] = "html",
    [M.language_kinds.csharp] = "roslyn",
    [M.language_kinds.razor] = "rzls",
}

M.notification = {
    razor_namedPipeConnect = "razor/namedPipeConnect",
    razor_initialize = "razor/initialize",
    razor_dynamicFileInfoChanged = "razor/dynamicFileInfoChanged",
    razor_provideDynamicFileInfo = "razor/provideDynamicFileInfo",
}

---@type table<string, vim.api.keyset.highlight>
--TODO: Extend this to cover all razor highlights
-- https://github.com/dotnet/vscode-csharp/blob/802be7399e947ab82f2a69780d43a57c1d5be6aa/package.json#L4761
local razor_highlights = {
    ["@lsp.type.razorComment"] = { link = "Comment" },
    ["@lsp.type.razorCommentStar"] = { link = "Comment" },
    ["@lsp.type.razorCommentTransition"] = { link = "Comment" },
    ["@lsp.type.controlKeyword"] = { link = "Statement" },
    ["@lsp.type.punctuation"] = { link = "@punctuation.bracket" },
    ["@lsp.type.razorTransition"] = { link = "Keyword" },
    ["@lsp.type.razorDirective"] = { link = "Keyword" },
    ["@lsp.type.razorDirectiveAttribute"] = { link = "Keyword" },
    ["@lsp.type.field"] = { link = "@variable" },
    ["@lsp.type.variable.razor"] = { link = "@variable" },
    ["@lsp.type.razorComponentElement.razor"] = { link = "@lsp.type.class" },
    ["@lsp.type.razorTagHelperElement.razor"] = { link = "@lsp.type.class" },
    ["@lsp.type.stringVerbatim.razor"] = { link = "@string" },
    ["@lsp.type.delegate.razor"] = { link = "@variable" },
    ["@lsp.type.constant.razor"] = { link = "@variable" },
    ["@lsp.type.razorComponentAttribute.razor"] = { link = "@lsp.type.property" },

    --Regex in string being passed to something like the Regex.Match()
    ["@lsp.type.regexComment.razor"] = { link = "Comment" },
    ["@lsp.type.regexCharacterClass.razor"] = { link = "@string.escape.regex" },
    ["@lsp.type.regexAnchor.razor"] = { link = "@punctuation.delimiter.regex" },
    ["@lsp.type.regexQuantifier.razor"] = { link = "@punctuation.operator.regex" },
    ["@lsp.type.regexGrouping.razor"] = { link = "@punctuation.bracket.regex" },
    ["@lsp.type.regexAlternation.razor"] = { link = "@operator.regex" },
    ["@lsp.type.regexText.razor"] = { link = "@string" },
    ["@lsp.type.regexSelfEscapedCharacter.razor"] = { link = "@string.regexp.regex" },
    ["@lsp.type.regexOtherEscape.razor"] = { link = "@string.regexp.regex" },

    --json in strings highlighting
    ["@lsp.type.jsonComment.razor"] = { link = "Comment" },
    ["@lsp.type.jsonNumber.razor"] = { link = "@number.json" },
    ["@lsp.type.jsonString.razor"] = { link = "@string.json" },
    ["@lsp.type.jsonKeyword.razor"] = { link = "Keyword" },
    ["@lsp.type.jsonText.razor"] = { link = "@string.json" },
    ["@lsp.type.jsonOperator.razor"] = { link = "@punctuation.operator" },
    ["@lsp.type.jsonPunctuation.razor"] = { link = "@punctuation.delimiter.json" },
    ["@lsp.type.jsonArray.razor"] = { link = "@punctuation.bracket.json" },
    ["@lsp.type.jsonObject.razor"] = { link = "@punctuation.bracket.json" },
    ["@lsp.type.jsonPropertyName.razor"] = { link = "@property.json" },
}

M.apply_highlights = function()
    for hl_group, hl in pairs(razor_highlights) do
        vim.api.nvim_set_hl(0, hl_group, hl)
    end
end

return M
