if exists("b:current_syntax")
    finish
endif

" Text Types -{{{
syntax match sentComment "\v^#.*$"
syntax match sentPicture "\v^\@.*$"
syntax match sentText "\v^\\.*$"
syntax match sentBlank "\v^\\\s*$"
syntax match sentCmd "\v^\$\s"
" }}}

" Bullets -{{{
syntax match sentBullet "\v^[0-9]*\."
syntax match sentBullet "\v^[0-9]*\)"

" If user has defined a bullet list add the default bullets to the list else
" create it
if exists("bulletlist")
	let g:bulletList = ['-', '▸', '→', '•', '◉'] + bulletlist
else
	if exists("newbulletlist")
		let g:bulletList = newbulletlist
	else
		let g:bulletList = ['-', '▸', '→', '•', '◉']
	endif
endif

" Syntax highlighting for the bullets
for i in g:bulletList
	execute "syntax match sentBullet '^" . i . " '"
endfor

let g:revBulletList = reverse(copy(g:bulletList))
" call reverse(g:bulletList)
" }}}

" Highlighting -{{{
highlight link sentBullet Identifier
highlight link sentComment Comment
highlight link sentPicture Constant
highlight link sentText Identifier
highlight link sentBlank String
highlight link sentCmd Label
" }}}

if !(exists("g:userRegister"))
	let g:userRegister = "q"
endif

let b:current_syntax = "sent"
" vim:foldmethod=marker
