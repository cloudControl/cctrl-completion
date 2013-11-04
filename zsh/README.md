# Cctrlapp autocompletion

Create new folder: `$HOME/.zsh-completions`
Add the following to your `.zshrc`:

~~~ zsh
# folder of all of your autocomplete functions
fpath=($HOME/.zsh-completions $fpath)

# enable autocomplete function
autoload -U compinit
compinitath)

# enable autocomplete function
autoload -U compinit
compinit
~~~

copy `_cctrlapp` into your `.zsh-completions` folder.
