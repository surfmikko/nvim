" Bare configuration for Vim 8/9.x / NVim
" vim: set ft=vimrc:

set nocompatible
syntax on
filetype plugin indent on

" Theme settings
set bg=dark
set showcmd
set modelines=1
set cmdheight=1

" Disable mouse (prevents terminal from losing click handling)
set mouse=

" Search settings
set ignorecase

" Default indent 4, only spaces, never tabs
set tabstop=4
set softtabstop=4 expandtab
set shiftwidth=4
set textwidth=79
set smarttab

" Use spacebar as leader key
let mapleader="\<Space>"


" Location list navigation (syntax check)
nnoremap <C-j> :lnext<CR>
nnoremap <C-k> :lprev<CR>

" Quickfix list navigation (Ggr / grep)
nnoremap <C-l> :cnext<CR>
nnoremap <C-h> :cprev<CR>

" Tab navigation
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<space>
nnoremap tm  :tabm<space>
nnoremap td  :tabclose<CR>

" Clear the search highlight with enter-key
nnoremap <silent> <CR> :noh<CR><CR>

" Statusline configuration
set laststatus=2
set statusline=%t\      "tail of the filename
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%{exists('g:loaded_fugitive')?FugitiveStatusline():''}

set statusline+=%=      "left/right separator

set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file

" Detect Python files by filename
au BufNewFile,BufRead *.py set filetype=python

" Ignore temporary files
set wildignore+=.pyc,**/.git/*,venv/*,.venv/*,*/build/lib/*,**/tmp/*,
set wildignore+=*.so,*.swp,*.zip,**/bower_components/*,**/node_modules/*

" Use gg=G to indent XML-files
au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

" Use :Ggr to open grep results in quick-fix list
:command! -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | cw | redraw!

" Bracketed paste — standard Vim only, Neovim handles this natively
if !has('nvim') && &term =~ "xterm.*"
	let &t_ti = &t_ti . "\e[?2004h"
	let &t_te = "\e[?2004l" . &t_te
	function! XTermPasteBegin(ret)
		set pastetoggle=<Esc>[201~
		set paste
		return a:ret
	endfunction
	map <expr> <Esc>[200~ XTermPasteBegin("i")
	imap <expr> <Esc>[200~ XTermPasteBegin("")
	vmap <expr> <Esc>[200~ XTermPasteBegin("c")
	cmap <Esc>[200~ <nop>
	cmap <Esc>[201~ <nop>
endif
