# Citatie

A neovim plugin to export bibtex citations to pandoc citation keys.

## Installation

Installation can be done via your favorite plugin manager. For vim-plug:

- Add `Plug 'nils-degroot/citatie'` to your `init.vim`
- Run `PlugInstall`

## Configuration

- `citatie_bib_files`: A list of bib files to read

### Example configuratio

```vim
let g:citatie_bib_files = [
    \ "/home/user/bibliography.bibtex"
    \ "/home/user/another-bibliography.bibtex"
    \]
```

## Usage

- `Citatie`
  - Gives you a window with all citations in format `{key} - {title}`. Use `i`
    to cite inline, i.e. `@citation_key`. Or use `f` or enter to citate full
    `[@citation_key]`. You can use `q` to close the window.
