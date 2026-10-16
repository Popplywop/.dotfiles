" Razor (.cshtml / .razor): HTML with embedded C#. Neovim detects both as `razor`.
if exists("b:current_syntax")
  finish
endif

runtime! syntax/html.vim
unlet! b:current_syntax
syntax include @razorCs syntax/cs.vim
unlet! b:current_syntax

syntax case match

" Nested braces / parens / brackets inside C# regions.
syntax region razorBrace   contained transparent start="{"  end="}"  contains=@razorCs,razorBrace,razorParen,razorBracket
syntax region razorParen   contained transparent start="("  end=")"  contains=@razorCs,razorBrace,razorParen,razorBracket
syntax region razorBracket contained transparent start="\[" end="\]" contains=@razorCs,razorBrace,razorParen,razorBracket

" @* comment *@
syntax region razorComment start="@\*" end="\*@" keepend contains=@Spell

" @@ escape
syntax match razorEscape "@@"

" Implicit expressions: @Model.Items[0].Name(args)
syntax match razorImplicit "\w\@<!@\h\w*\%(\.\h\w*\|\[[^\]]*\]\|([^)]*)\)*" contains=razorAt,razorImplicitBody
syntax match razorAt contained "@"
syntax match razorImplicitBody contained "\h\w*\%(\.\h\w*\|\[[^\]]*\]\|([^)]*)\)*" contains=@razorCs

" @{ code block }, @functions { }, @code { }
syntax region razorBlock matchgroup=razorDelim start="@{" end="}" keepend contains=@razorCs,razorBrace,razorParen,razorBracket,razorMarkupTag
syntax region razorBlock matchgroup=razorDelim start="@\%(functions\|code\)\s*{"rs=s+1 end="}" keepend contains=@razorCs,razorBrace,razorParen,razorBracket

" @( explicit expression )
syntax region razorExplicit matchgroup=razorDelim start="@(" end=")" keepend contains=@razorCs,razorBrace,razorParen,razorBracket

" @if (...) / @foreach (...) etc. Only the C# header is matched; the braces
" stay in markup context so nested HTML keeps its colours.
syntax match  razorKeyword "@\%(if\|else\|for\|foreach\|while\|do\|switch\|try\|catch\|finally\|lock\|using\)\>"
syntax region razorControl matchgroup=razorKeyword start="@\%(if\|for\|foreach\|while\|switch\|lock\|using\)\s*("rs=e-1 end=")" keepend contains=@razorCs,razorParen,razorBracket
syntax region razorControl matchgroup=razorKeyword start="\<\%(else\s\+if\|catch\)\s*("rs=e-1 end=")" keepend contains=@razorCs,razorParen,razorBracket

syntax match razorKeyword "^\s*\zs\%(else\|}\s*else\)\>"

" Directives: @model Foo, @using X, @inject T n, @page "/x" ...
syntax region razorDirective matchgroup=razorKeyword
      \ start="^\s*@\%(page\|model\|using\|inject\|layout\|namespace\|inherits\|implements\|rendermode\|attribute\|typeparam\|preservewhitespace\|addTagHelper\|removeTagHelper\|tagHelperPrefix\|section\|inherits\)\>"
      \ end="$" oneline keepend contains=@razorCs

" Make Razor constructs usable inside tags/attributes/strings and markup.
syntax cluster htmlPreproc add=razorComment,razorEscape,razorBlock,razorExplicit,razorKeyword,razorControl,razorImplicit
syntax cluster htmlTop     add=razorComment,razorEscape,razorBlock,razorExplicit,razorKeyword,razorControl,razorImplicit,razorDirective

highlight default link razorComment Comment
highlight default link razorEscape  SpecialChar
highlight default link razorDelim   PreProc
highlight default link razorAt      PreProc
highlight default link razorKeyword Statement
highlight default link razorDirective Normal

let b:current_syntax = "razor"
