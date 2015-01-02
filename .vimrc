" ================ Pathogen =========================
execute pathogen#infect()
filetype plugin indent on

" ================ General Config ====================
syntax on                       " Turn on that syntax highlighting
colorscheme lucius              " Set colorscheme
set nocompatible                " Forget being compatible with good ol' vi
set title                       " change the terminal's title
set number                      " Sne number
set backspace=indent,eol,start  " Allow backspace in insert mode
set history=1000                " Store lots of :cmdline history
set showcmd                     " Show incomplete cmds down the bottom
set showmode                    " Show current mode down the bottom
set gcr=a:blinkon0              " Disable cursor blink
set visualbell                  " No sounds
set autoread                    " Reload files changed outside vim
set hls                         " Higlight search
set lazyredraw                  " Don't update the display while executing macros
set wildmenu                    " Enable enhanced command-line completion.
set laststatus=2                " tell Vim to always put a status line in
set mousehide                   " Hide mouse while typing
set cursorline                  " Highlight current line
set background=light            " Set backgroung for colorscheme
set encoding=utf-8              " Set encoding
set colorcolumn=80              " Highlight column at 80
set antialias                   " Set antialias for VIM
set noswapfile
set nobackup
set nowb
let NERDTreeQuitOnOpen=1        " NERDTree will close after opening a file


" =============== Persistent Undo ========================
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" ================ Completion =======================
set wildmode=list:longest
set wildmenu "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem "Disable output and VCS files
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.dmg "Disable archive files
set wildignore+=*.pdf,*.ai,*.psd,*.doc,*.gdoc,*.jpeg,*.jpg,*.jpeg,*.png,*.gif "Disable archive files
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/vendor/rails/*,*/.bundle/*,*/.sass-cache/* "Ignore bundler and sass cache
set wildignore+=*.swp,*~,._*,*/.AppleDouble*,*.DS_STORE,log/**,tmp/**,*vim/backups* "Disable temp and backup files


" ================ Status Line =======================
set stl=%F\ %m\ %r\ %=\ Line:\ %l/%L[%p%%]\ Col:\ %c\ %y
" Vim-Airline
let g:airline_powerline_fonts = 1

" ================ Misc =======================
" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

" Smart search casing
set ignorecase
set smartcase

" Get that filetype stuff happening
filetype on
filetype plugin on
filetype indent on

" Incrementally match the search.  I orignally hated this
" but someone forced me to live with it for a while and told
" me that I would grow to love it after getting used to it...
" turns out he was right :)
set incsearch

" ================ Indentation ======================
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:`
set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Scrolling =======================
set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" Scroll faster with ctrl+e and ctrl+y
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" ================== Key Mappings ==================
" Change <leader> to comma
:let mapleader = ","

" toggle highlight.
nmap <silent> // :silent :nohlsearch<CR>

" Insert semicolon at the end of line
nmap <silent> ;; A;<ESC>

" Trim whitespaces at the end of lines
nmap <silent> <leader>t :%s/\s\+$//<CR>

" tComment mappings
map <D-/> <c-_><c-_>

" NERDtree mappings
map <silent> <leader>s :NERDTreeToggle<CR>

" Let's make it easy to edit this file (mnemonic for the key sequence is 'e'dit 'v'imrc)
nmap <silent> <leader>ev :e $MYVIMRC<cr>

" And to source this file as well (mnemonic for the key sequence is 's'ource 'v'imrc)
nmap <silent> <leader>sv :so $MYVIMRC<cr>

" Remap for better window navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Map for emacs like navigation in insert mode
imap <C-b> <Left>
imap <C-f> <Right>
imap <C-e> <End>


nmap <silent> <F5> :DARK<CR>
nmap <silent> <F6> :LIGHT<CR>

" ================== Commands ==================
" Command Aliases
command! DARK set background=dark
command! LIGHT set background=light

" ================== NeoComplete ==================
" NeoComplete
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>""
" Move up and down in autocomplete with <c-j> and <c-k>
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction

