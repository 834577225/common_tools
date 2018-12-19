set nu
" std tags
set tags+=~/.vim/tags/cpp_src/tags
" pathogen config
execute pathogen#infect()
syntax on
filetype plugin indent on
" NERDTree config
map <C-n> :NERDTree<CR>
" MiniBufExplorer config
let g:miniBufExplMaxSize = 2
" taglist config
let Tlist_Show_One_File=1    " 只展示一个文件的taglist
let Tlist_Exit_OnlyWindow=1  " 当taglist是最后以个窗口时自动退出
let Tlist_Use_Right_Window=1 " 在右边显示taglist窗口
let Tlist_Sort_Type="name"   " tag按名字排序
" OmniCppComplete config
filetype plugin indent on
set completeopt=longest,menu
let OmniCpp_NamespaceSearch = 2     " search namespaces in the current buffer   and in included files
let OmniCpp_ShowPrototypeInAbbr = 1 " 显示函数参数列表
let OmniCpp_MayCompleteScope = 1    " 输入 :: 后自动补全
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]"]"

