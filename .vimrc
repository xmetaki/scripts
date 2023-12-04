" remember create .vim/bundle folder
let mapleader=" "
syntax on
inoremap jk <ESC>
set nu
set relativenumber
set title

nnoremap sv <C-w>v
nnoremap sh <C-w>h
nnoremap sc <C-w>q
nnoremap <leader>e <C-w>w

set ts=4
set expandtab
set shiftwidth=4
set smarttab
set autoindent
set nohls
set ruler
filetype on

set cursorline
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin  'VundleVim/Vundle.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'scrooloose/nerdtree'
Plugin 'itchyny/lightline.vim'
Plugin 'vim-scripts/Solarized.git'

call vundle#end()

map <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)
map <Leader>d :NERDTreeToggle<CR>
let NERDTreeWinSize=35

set laststatus=2
let g:lightline={'colorscheme': 'PaperColor'}
"colorscheme solarized
set autochdir
