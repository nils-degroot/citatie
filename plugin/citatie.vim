" Last Change:  2021 Okt 24
" Maintainer:   Nils de Groot <nils@peeko.nl>
" License:      GNU General Public License v3.0

if exists('g:loaded_citatie') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! Citatie lua require'citatie'.open_window()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_citatie = 1
