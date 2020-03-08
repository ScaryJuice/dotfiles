call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
call plug#end()

let g:airline_powerline_fonts = 1

colorscheme gruvbox

set background=dark
set number
set wildmenu
set wildmode=longest:full,full
set cul

syntax enable
