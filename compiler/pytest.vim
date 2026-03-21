" Compiler plugin for pytest
" Usage: :compiler pytest

if exists("current_compiler")
    finish
endif
let current_compiler = "pytest"

CompilerSet makeprg=pytest\ --tb=line\ --lf\ --lfnf=all

" Errorformat patterns (evaluated top to bottom, first match wins):
"   - Skip frames from site-packages, frozen internals, /Library, /usr
"   - Match syntax errors: multi-line 'E     File "f", line N' + 'E   msg'
"   - Match standard errors: file:line: message
"   - Ignore everything else
CompilerSet errorformat=
    \%-G%.%#site-packages%.%#,
    \%-G%.%#<frozen%.%#,
    \%-G/Library/%.%#,
    \%-G/usr/%.%#,
    \%AE\ \ \ \ \ File\ \"%f\"\\,\ line\ %l,
    \%-C%.%#,
    \%ZE\ \ \ %m,
    \%f:%l:\ %m,
    \%-G%.%#
