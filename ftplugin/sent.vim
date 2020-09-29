" Change List Header -{{{
function! ChangeListHead(reverse)

	" Use different lists for different directions
	if a:reverse == "false"
		let useList = g:bulletList
	else
		let useList = g:revBulletList
	endif

	" Check the header of the list item
	if getline('.') =~? '^[0-9]*\.'

		" Check if direction is reverse
		if a:reverse == "false"

			" It is not; change '.' to ')'
			execute "normal! 0f.r)"
		else

			" It is; change '.' to last bullet if not empty or '.'
			if len(useList) > 0
				execute "normal! 0\"_cf " . useList[0] . ' '
			else
				execute "normal! 0f.r)"
			endif
		endif

	elseif getline('.') =~? '^[0-9]*)'

		if a:reverse == "false"

			" Check if the bullets list is empty
			if len(useList) > 0

				" Change to the next bullet
				execute "normal! 0\"_cf)" . useList[0]
			else

				" Change to '.'
				execute "normal! 0f)r."
			endif
		else
			execute "normal! 0f)r."
		endif
	else

		" The bullet index to change to
		let finalbullet = 1

		" Check if the bullet list has any items
		if len(useList) > 0

			" Go through the bullets list
			for i in useList

				" Check if the current line has the current loop
				" bullet
				if getline('.') =~? ('^' . i . '\s')

					" Check if the loop has not reached
					" the end of the loop
					if finalbullet < len(useList)

						" Change the bullet to the next bullet
						execute "normal! 0r" . useList[finalbullet]
						break
					else

						" Change it to a numbered list
						" and refresh the numbers
						if a:reverse == "false"
							execute "normal! 0\"_ct 1."
							silent! call RedrawNumbers()
						else
							execute "normal! 0\"_ct 1)"
							silent! call RedrawNumbers()
						endif
					endif
				else

					" Check if the loop has reached the end of the
					" list
					if finalbullet == (len(useList) - 1)

						" Check if the current line is a valid
						" list item
						if getline('.') =~? useList[(len(useList) - 1)]

							" Change it to a numbered list
							" and refresh the numbers
							if a:reverse == "false"
								execute "normal! 0\"_ct 1."
								silent! call RedrawNumbers()
							else
								execute "normal! 0\"_ct 1)"
								silent! call RedrawNumbers()
							endif
						endif
					else

						" The list has not reached its end;
						" Increment the final bullet index
						let finalbullet += 1
					endif
				endif
			endfor
		endif
	endif
endfunction
" }}}

" Create Item Below -{{{
function! CreateItemBelow()

	" Check if the current line is a valid list item
	if getline('.') =~? '^[0-9]*\.'

		" Get the current line number
		let currlinenum = getline('.') + 0

		" Create a new item
		execute "normal! o" . (currlinenum + 1) . ". "

		" Reload list numbers
		silent! call RedrawNumbers()

		" Start appending
		startinsert!

	" Other list formats
	elseif getline('.') =~? '^[0-9]*)'
		let currlinenum = getline('.') + 0
		execute "normal! o" . (currlinenum + 1) . ") "
		silent! call RedrawNumbers()
		startinsert!

	else
		let createdline = 0

		for i in g:bulletList
			if getline('.') =~? ('^' . i . '\s')
				let createdline = 1
				execute "normal! o" . i . " "
				break
			endif
		endfor
		if !(createdline)
			execute "normal! o"
		endif
		startinsert!
	endif
endfunction
" }}}

" Create Item Above -{{{
function! CreateItemAbove()

	" Check if the current line is a valid list item
	if getline('.') =~? '^[0-9]*\.'

		" Get the current line number
		let currlinenum = getline('.') + 0

		" Create a new item
		execute "normal! O" . (currlinenum - 1) . ". "

		" Reload numbers
		silent! call RedrawNumbers()

		" Start appending
		startinsert!

	" Other list formats
	elseif getline('.') =~? '^[0-9]*)'
		let currlinenum = getline('.') + 0
		execute "normal! O" . (currlinenum - 1) . ") "
		silent! call RedrawNumbers()
		startinsert!

	else
		let createdline = 0

		for i in g:bulletList
			if getline('.') =~? ('^' . i . '\s')
				let createdline = 1
				execute "normal! O" . i . " "
				break
			endif
		endfor
		if !(createdline)
			execute "normal! O"
		endif
		startinsert!
	endif
endfunction
" }}}

" Move an item down -{{{
function! ListMoveDown()
	" Get the current row and column number
	let currlinenum = line('.')
	let currcolnum = virtcol('.')

	" Check if the line below is a valid list item
	execute "normal! j"
	if getline('.') =~? '^[0-9]*\.' && currlinenum < line('$')

		" Get the number of the list item and go back to the original
		" position
		execute "normal! k"
		let curritemnum = getline('.')

		" Move the current item down and set the item number to the item
		" number of the list item that previously occupied it
		execute "normal! \"" . g:userRegister . "dd\"" . g:userRegister . "p0\"_ct." . (curritemnum + 1)

		" Move up and decrement the item number of the list item
		execute "normal! k"
		execute "normal! 0\"_ct." . (curritemnum + 0)

		" Go back to the initial cursor position
		execute "normal! j"
		if currcolnum > 1
			execute "normal! " . (currcolnum - 1) . "l"
		endif

		" Redraw the numbers to get proper item numbers
		silent! call RedrawNumbers()

	" Same process,however instead of '.', it works with ')'
	elseif getline('.') =~? '^[0-9]*)' && currlinenum < line('$')
		let curritemnum = getline('.')
		execute "normal! k"
		execute "normal! \"" . g:userRegister . "dd\"" . g:userRegister . "p0\"_ct)" . (curritemnum + 0))
		execute "normal! k"
		execute "normal! 0\"_ct)" . (curritemnum - 1)
		execute "normal! j"
		if currcolnum > 1
			execute "normal! " . (currcolnum - 1) . "l"
		endif
		silent! call RedrawNumbers()

	" Normal list item movement
	elseif currlinenum < line('$')

		let movedline = 0


		" Check through the bullets list for the bullet on the current
		" line
		for i in g:bulletList

			" Check if the current line has the current loop
			" bullet
			if getline('.') =~? ('^' . i . '\s')

				" The line will be moved
				let movedline = 1

				" Move the line
				execute "normal! k"
				execute "normal! \"" . g:userRegister . "dd"
				execute "normal! \"" . g:userRegister . "p0"

				if currcolnum > 1
					execute "normal! " . (currcolnum - 1) . "l"
				endif
				break
			endif
		endfor

		" Check if the line was not moved
		if !(movedline)

			" Go back to the original paragraph
			if getline('.') =~? '^$'
				execute "normal! k"
			endif
		endif
	endif
endfunction
" }}}

" Move an item up -{{{
function! ListMoveUp()
	" Get the current row and column number
	let currcolnum = virtcol('.')
	let currlinenum = line('.')

	" Check if the line above is a valid list item
	execute "normal! k"
	if getline('.') =~? '^[0-9]*\.' && currlinenum > 1

		" Get the number of the list item and go back to the original
		" position
		let curritemnum = getline('.')
		execute "normal! j"

		" Move the current item up and set the item number to the item
		" number of the list item that previously occupied it
		execute "normal! \"" . g:userRegister . "dd"
		if currlinenum <= line('$')
			execute "normal! k"
		endif
		execute "normal! \"" . g:userRegister . "P0\"_ct." . (curritemnum + 0)

		" Move down and increment the item number of the list item
		execute "normal! j"
		execute "normal! 0\"_ct." . (curritemnum + 1)

		" Go back to the initial cursor position
		execute "normal! k"
		if currcolnum > 1
			execute "normal! " . (currcolnum - 1) . "l"
		endif

		" Redraw the numbers to get proper item numbers
		silent! call RedrawNumbers()

	" Same process,however instead of '.', it works with ')'
	elseif getline('.') =~? '^[0-9]*)' && currlinenum > 1
		let curritemnum = getline('.')
		execute "normal! j"
		execute "normal! \"" . g:userRegister . "dd"
		if line('.') < line('$')
			execute "normal! k"
		endif
		execute "normal! \"" . g:userRegister . "P0\"_ct)" . (curritemnum + 0)
		execute "normal! j"
		execute "normal! 0\"_ct)" . (curritemnum + 1)
		execute "normal! k"
		if currcolnum > 1
			execute "normal! " . (currcolnum - 1) . "l"
		endif
		silent! call RedrawNumbers()

	" Normal list item movement
	elseif currlinenum > 1

		let movedline = 0

		" Check through the bullets list for the bullet on the current
		" line
		for i in g:bulletList

			" Check if the current line has the current loop
			" bullet
			if getline('.') =~? ('^' . i . '\s')

				" The line will be moved
				let movedline = 1

				" Move the line
				execute "normal! j"
				execute "normal! \"" . g:userRegister . "dd"

				if currlinenum < (line('$') + 1)
					execute "normal! k"
				endif
				execute "normal! \"" . g:userRegister . "P0"
				if currcolnum > 1
					execute "normal! " . (currcolnum - 1) . "l"
				endif
				break
			endif
		endfor

		" If the line was not moved go down a line
		if !(movedline)
			execute "normal! j"
		endif
	endif
endfunction
" }}}

" Redraw numbers -{{{
function! RedrawNumbers()

	" Save the current cursor position and go to the beginning of the paragraph
	let currlinenum = line('.')
	let currcolnum = virtcol('.')

	silent! execute "normal! {)"

	" Repeat till end of paragraph or file
	while getline('.') !~? '^$' && line('.') < line('$')

		" Check if the current line is a valid list item
		if getline('.') =~? '^[0-9]*\.'
			" The line number to be set at the first list item
			let finallinenum = 1

			" Go through all the list items and increment the
			" number for each item
			while getline('.') =~? '^[0-9]*\.' && line('.') < line('$')
				execute "normal! 0\"_ct." . finallinenum
				execute "normal! j"
				let finallinenum+=1
			endwhile

			" Check if the current line is the last line and is a
			" valid list item
			if line('.') == line('$') && getline('.') =~? '^[0-9]*\.'
				execute "normal! 0\"_ct." . finallinenum
				let finallinenum+=1
			endif

			" Same except works on the ')' character instead of '.'
		elseif getline('.') =~? '^[0-9]*)'
			let finallinenum = 1
			while getline('.') =~? '^[0-9]*)' && line('.') < line('$')
				execute "normal! 0\"_ct)" . finallinenum
				execute "normal! j"
				let finallinenum+=1
			endwhile
			if line('.') == line('$') && getline('.') =~? '^[0-9]*)'
				execute "normal! 0\"_ct)" . finallinenum
				let finallinenum+=1
			endif
		else
			execute "normal! j"
		endif
	endwhile

	" Go to the original cursor position
	execute "normal! " . currlinenum . "G0"
	if currcolnum > 1
		execute "normal! " . (currcolnum - 1) . "l"
	endif
endfunction
" }}}

" Move Paragraph Down -{{{
function! ParaMoveDown()

	let paramoved = 0

	" Get the current column and row
	let currcolnum = virtcol('.')
	let currlinenum = line('.')

	" Go at the end of the current paragraph
	execute "normal! }"

	" Check if the current line is lesser than the last line
	if line('.') < line('$')

		" Go to the original row
		execute "normal! " . currlinenum . "G"

		" Delete the paragraph, go after the next paragraph and paste it
		" between two newly created blank lines
		execute "normal! \"" . g:userRegister . "dip}o"
		execute "normal! o"
		execute "normal! \"" . g:userRegister . "P"

		" Delete the blank line at the bottom of the moved paragraph if there
		" are two blank lines at the end
		execute "normal! }"
		if getline('.') =~? '^$'
			execute "normal! j"
			if getline('.') =~? '^$'
				execute "normal! \"_dd"
			endif
			execute "normal! k"
		endif

		" Go to the beginning of the paragraph
		execute "normal! {"

		" Delete the blank line if there are two blank lines
		if getline('.') =~? '^$'
			execute "normal! k"
			if getline('.') =~? '^$'
				execute "normal! \"_dd"
			endif
		endif

		" Go to the beginning of the paragraph
		execute "normal! {"

		" Delete blank lines
		if getline('.') =~? '^$'
			execute "normal! k"
			if getline('.') =~? '^$'
				execute "normal! \"_dd"
			endif
		endif

		" Go to the next paragraph
		execute "normal! })"

		let paramoved = 1
	endif

	" Position the cursor where it was
	if !(paramoved)
		execute "normal! " . currlinenum . "G"
	endif

	if currcolnum > 1
		execute "normal! " . (currcolnum - 1) . "l"
	endif

endfunction
" }}}

" Move Paragraph Up -{{{
function! ParaMoveUp()

	let paramoved = 0

	" Get the current column
	let currcolnum = virtcol('.')
	let currlinenum = line('.')

	" Go to top of the paragraph and get the line number
	execute "normal! {)"
	let paratopline = line('.')

	" Go to the original row
	execute "normal! " . currlinenum . "G"

	" Check if the paragraph is not the first paragraph in the file
	if paratopline > 1
		" Delete the paragraph, go before the previous paragraph and paste it
		" between two newly created lines
		execute "normal! \"" . g:userRegister . "dip{O"
		execute "normal! O"
		execute "normal! \"" . g:userRegister . "p"

		" Go down two paragraphs and delete the blank line if two are present
		execute "normal! }}"
		if getline('.') =~? '^$'
			execute "normal! j"
			if getline('.') =~? '^$'
				execute "normal! \"_dd"
			endif
			execute "normal! k"
		endif

		" Go up a paragraph and delete a line if two are present
		execute "normal! {"
		if getline('.') =~? '^$'
			execute "normal! k"
			if getline('.') =~? '^$'
				execute "normal! \"_dd"
			endif
		endif

		" Go up a paragraph and delete a line if two are present
		execute "normal! {"
		if line('.') == 1
			execute "normal! \"_dd"
		else
			execute "normal! j"
		endif

		let paramoved = 1
	endif

	" Position the cursor where it was
	if !(paramoved)
		execute "normal! " . (currlinenum) . "G"
	endif

	if currcolnum > 1
		execute "normal! " . (currcolnum - 1) . "l"
	endif
endfunction
" }}}

" Toggle State -{{{
function! ToggleState(string)

	" The current column of the cursor
	let currcolnum = virtcol('.')

	" Check if the line begins with the string
	if getline('.') =~? a:string

		" Get rid of the string
		execute "normal! 0" . len(a:string) . "\"_x"

		" Move the cursor to its original position
		if currcolnum > (len(a:string) + 1)
			execute "normal! " . (currcolnum - (len(a:string) + 1)) . "l"
		endif
	else
		" Check if the line is not empty
		if getline('.') !~? '^$'

			" Add the string at the beginning
			execute "normal! I" . a:string

			" Move the cursor to its original position
			execute "normal! " . (currcolnum) . "l"
		endif
	endif
endfunction
" }}}

" Toggle List Item Headers -{{{
function! ToggleListHeaders(reverse)

	" Get the original cursor position
	let origlinenum = line('.')
	let origcolnum = virtcol('.')

	" Change the List Headers
	silent! execute "normal! vip:call ChangeListHead(a:reverse)\<cr>"
	silent! call RedrawNumbers()

	" Move the cursor back to its original position
	execute "normal! " . origlinenum . "G0"
	if origcolnum > 1
		execute "normal! " . (origcolnum - 1) . "l"
	endif
endfunction
" }}}

" Mappings -{{{

" Toggle States
nnoremap <silent> gcc :call ToggleState("# ")<cr>
nnoremap <silent> gcap vip:call ToggleState("# ")<cr>
vnoremap <silent> gc :call ToggleState("# ")<cr>

nnoremap <silent> gdd :call ToggleState("\\")<cr>
nnoremap <silent> gdap vip:call ToggleState("\\")<cr>
vnoremap <silent> gd :call ToggleState("\\")<cr>

nnoremap <silent> gpp :call ToggleState("@")<cr>
nnoremap <silent> gpap vip:call ToggleState("@")<cr>
vnoremap <silent> gp :call ToggleState("@")<cr>

nnoremap <silent> <tab> :call ToggleListHeaders("false")<cr>
nnoremap <silent> <s-tab> :call ToggleListHeaders("true")<cr>

" List Item Movement
nnoremap <silent> J :call ListMoveDown()<cr>
nnoremap <silent> K :call ListMoveUp()<cr>

" Paragraph Movement
nnoremap <silent> <C-j> :call ParaMoveDown()<cr>
nnoremap <silent> <C-k> :call ParaMoveUp()<cr>

" Redraw numbers
nnoremap <silent> <C-a> :call RedrawNumbers()<cr>

" Create new items
nnoremap <silent> o :call CreateItemBelow()<cr>
nnoremap <silent> O :call CreateItemAbove()<cr>
inoremap <silent> <return> <esc>:call CreateItemBelow()<cr>

" Create normal lines
nnoremap <silent> cr A<cr>
inoremap <silent> <tab> <cr>

" Open Preview
nnoremap <silent> <F5> :!sent % & disown<cr><cr>
" }}}

" Abbreviations -{{{
iabbrev . •
iabbrev -> →
" }}}

" vim:foldmethod=marker
