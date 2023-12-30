#set page(
  paper: "presentation-16-9",
  columns: 2,
  margin: (top: 2.5cm, bottom: 1cm, right: 1cm, left: 1cm),
  header: rect(fill: rgb("#d2ebfc"))[
      #box(
        baseline: 30%,
        height: 40pt,
        image("neovim-mark.svg")
      )
      #h(0.25cm)
      #text(
        font: "Nunito Sans 10pt",
        style: "normal",
        weight: "black",
        size: 21pt,
        fill: rgb("#2887ed")
      )[Neo]#text(
        font: "Nunito Sans 10pt",
        style: "normal",
        weight: "black",
        size: 21pt,
        fill: rgb("#3f9940")
      )[Vim] #text(
        font: "Nunito Sans 10pt",
        style: "normal",
        weight: "black",
        size: 21pt
      )[commands and shortcuts cheatsheet]
  ]
)
#set text(
  font: "Hanken Grotesk",
  size: 10pt
)

#show raw: set text(
  font: "Inconsolata",
  size: 11pt,
  fill: rgb("#222222")
)

#show heading: set text(
  font: "Nunito Sans 10pt",
  style: "normal",
  weight: "black"
)

#let light_blue = rgb("#b9e6fa")
#let medium_blue = rgb("#438bab") 

#let command() = {
  h(0.1cm)
  box(baseline: 20%, height: 10pt, image("command-mode.png"))
  h(0.1cm)
}
#let normal() = {
  h(0.1cm)
  box(baseline: 20%, height: 10pt, image("normal-mode.png"))
  h(0.1cm)
}
#let insert() = {
  h(0.1cm)
  box(baseline: 20%, height: 10pt, image("insert-mode.png"))
  h(0.1cm)
}
#let visual() = {
  h(0.1cm)
  box(baseline: 20%, height: 10pt, image("visual-mode.png"))
  h(0.1cm)
}

#let hyperlink(text_to_show, link_to: none) = {
  set text(fill: blue)
  link(link_to)[#text_to_show]
}



= Conventions in this cheatsheet

All Vim commands or shortcuts exposed in this cheatsheet are written
in monospaced font, like `/{pattern}` for searching for a pattern over the
current file.

Also all Vim commands or shortcuts are accompanied by the logo of the Vim mode
you need to be in order to use that command/shortcut. For example, if you see the shortcut
"#normal() `gj`", this means that to use this shortcut, you need to enter into normal mode,
and then, you press the keys "g" and "j" (one after another) on your keyboard.

When you need to hold down a sequence of keys together, we will use the plus 
sign (`+`). So, for example, the shortcut `<Space> + f` means: "press and hold down the `<Space>`
key, then, press the `f` key".

When you need to provide some input to the command/shortcut, like a pattern to search for, or a number of lines
to jump, then this input will be surrounded by curly brackets (`{` and `}`). So if you see `{pattern}`
inside a shortcut/command, this means that you need to type a pattern in the place
of this `{pattern}`.

= Vim modes

- Enter visual mode: being in #normal() mode, press `v`, and then, press any key that moves the cursor, such as the arrow keys, or the keys `w`, `b`, `e` and `{`
- Enter command mode: #normal() `:`
- Enter insert mode: #normal() `i`
- Go back into normal mode: #insert() #visual() #command() `<Esc>`

= Quit Neovim | Create, Save and Close files

- Save the current file: #command() `:w`
- Create a new text file: #command() `:e {name of the new file}`, then, use the save command #command() `:w` to save this new file into your system.
- Close everything (all active windows), and then, Quit/Exit NeoVim: #command() `:qa`
- Close the current window (this works for any kind of window in NeoVim, e.g. a plugin window, a tab or a splitted window). However, if you have only one window active, then, this command will actually Quit/Exit NeoVim: #command() `:q`

= Move cursor

- Move left #normal() `h` or the left arrow `<Left arrow>`
- Move down #normal() `j` or the down arrow `<Down arrow>`
- Move up #normal() `k` or the up arrow `<Up arrow>`
- Move right #normal() `l` or the right arrow `<Right arrow>`
- Jump to the beginning of the next word #normal() `w`
- Jump to the end of the next word #normal() `e`
- Jump to the beginning of the current/previous word #normal() `b`
- Jump to the start of the current line #normal() `0`
- Jump to the first non-blank character of the current line #normal() `_`
- Jump to the end of the current line #normal() `$`
- Jump to previous line that is blank #normal() `{`
- Jump to next line that is blank #normal() `}`
- Jump to the first line of the current file: #normal() `gg`
- Jump to the last line of the current file: #normal() `G`

= Search and replace

If you only type #normal() `/{pattern}`, then NeoVim will just highlight the matches found in the current file.
However, if type #normal() `/{pattern}` and then press `Enter`, NeoVim will move the cursor to the first match
found in the file. You can also press the `n` key over and over again to navigate through all matches found across the file.

- Search for a pattern over the next lines: #normal() `/{pattern}`
- Search for a pattern over the previous lines: #normal() `?{pattern}`
- Search and replace the first occurrence of a pattern over the current line: #command() `:s/{pattern}/{replacement}`
- Search and replace the first occurrence of a pattern over all lines: #command() `:%s/{pattern}/{replacement}`
- Search and replace all occurrences of a pattern over the current line: #command() `:%s/{pattern}/{replacement}/g`
- Search and replace all occurrences of a pattern over all lines: #command() `:%s/{pattern}/{replacement}/g`


= Comment lines

- Comment current line: #normal() `gcc` or `gbc`
- Comment multiple lines at once: being in #normal() mode, press `v`, then, move the cursor in any possible way to enter #visual() mode. Then, if you do enter visual mode, start to move the cursor to mark the lines you want to comment. After you marked the lines you want, you can type `gc` or `gb` to comment them. 

= Copy and paste text

- Copy (or _yank_) text: #normal() `y`
- Paste copied text: #normal() `p`
- Copy current line: #normal() `yy`
- Copy multiple lines at once: being in #normal() mode, press `v`, then, move the cursor in any possible way to enter #visual() mode. Then, if you do enter visual mode, start to move the cursor to mark the lines you want to copy. After you marked the lines you want, you can type `y` to copy them. 

= Insert mode, start writing new code

- Enter insert mode before the cursor: #normal() `i`
- Enter insert mode at the beginning of the current line: #normal() `I`
- Enter insert mode after the cursor (append): #normal() `a`
- Enter insert mode at the end of the current line (append): #normal() `A`
- Create a new line below the current line, move the cursor to this new line, and then, enter insert mode: #normal() `o`
- Create a new line above the current line, move the cursor to this new line, and then, enter insert mode: #normal() `O`


= Indentation and code style

- Reindent the entire file: #normal() `gg=G`
- Reformat the entire file using the code style of by the LSP #footnote[This command will use the current LSP to reformat your source code, so it conforms with the code style recommended by this LSP. For example, if you are editing a C source file, you are likely using the `clang` LSP. Then, this `:Format` command would apply the code style recommended by the `clang` LSP over the current file]: #command() `:Format`

- Add more indentation (i.e. move right) to the current line #insert() `<Ctrl> + t`
- Subtract indentation (i.e. move left) of the current line #insert() `<Ctrl> + d`


= Delete content

- Delete current line #normal() `dd`
- Delete current word #normal() `bdw`
- Delete previous word #normal() `db`
- Delete next word #normal() `wdw`
- Mark multiple lines and delete them at once: being in #normal() mode, press `v`, then, move the cursor in any possible way to enter #visual() mode. Then, if you do enter visual mode, start to move the cursor to mark the lines you want to delete. After you marked the lines you want, just press `d` to delete them.


= Opening multiple files across different tabs

You can have multiple files open at the same time in NeoVim.
You just have to open these files in different tabs.

- Open the file in a new tab: #command() `:tabnew {path to file}`
- Go to next tab: #command() `:tabn`
- Go to previous tab: #command() `:tabp`
- Close the current tab: #command() `:tabc` or `:tabclose`


= Useful commands from the Telescope plugin

The #hyperlink(link_to: "https://github.com/nvim-telescope/telescope.nvim")[`Telescope` NeoVim plugin] is an extremelly useful plugin, and
you should have it installed in your NeoVim. It provides many useful shortcuts for searching files and patterns across your project.

- List all shortcuts activated by Telescope (this is very useful when you don't remember the shortcut you are looking for): #command() `:Telescope keymaps`
- Search for a file in your current working directory: #normal() `<Space>sf`
- Search for a file in your "recently opened files" list #footnote[This is an interesting shortcut because this "recently opened files" also contains files that are outside of your current working directory (or your current project).]: #normal() `<Space>?`
- Search for all occurrences of a pattern across your current working directory (or project): #normal() `<Space>sw` or `<Space>sg`


= Package Manager (Mason)

#hyperlink(link_to: "https://github.com/williamboman/mason.nvim")[Mason] is the most popular package manager for NeoVim,
and is the most effective way of installing NeoVim plugins.

- Opens the Mason package manager: #command() `:Mason`
- Search for a specific package/plugin: inside Mason use the normal Vim search command `/{pattern}`.
- Install a specific package/plugin: if the cursor is over the package, press `i` to install it.

/*
Example "#normal() `/token`" -> #raw("void ")
#box(fill: light_blue, stroke: medium_blue, raw("token"))
#raw("TokenType type) {")
*/