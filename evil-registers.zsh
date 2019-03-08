# {{{ set system clipboard
zmodload zsh/parameter
declare -gA ZSH_EVIL_PASTE_HANDLERS
declare -gA ZSH_EVIL_COPY_HANDLERS
# "(e)*" to remove special meaning of "*"
if (( $+commands[termux-clipboard-get] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-termux-clipboard-get}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-termux-clipboard-get}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-termux-clipboard-set}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-termux-clipboard-set}"
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-wl-paste -p -n}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-wl-paste -n}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-wl-copy -p}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-wl-copy}"
elif (( $+DISPLAY & $+commands[xclip] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-xclip -out}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-xclip -selection clipboard -out}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-xclip}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-xclip -selection clipboard}"
elif (( $+DISPLAY & $+commands[xsel] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-xsel -o}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-xsel -b -o}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-xsel -i}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-xsel -b -i}"
fi
(( ${#ZSH_EVIL_PASTE_HANDLERS} + ${#ZSH_EVIL_COPY_HANDLERS} )) || return
# }}}
# {{{ shadow all vi commands
fpath+="${0:h}"
autoload -Uz _evil-register-paste _evil-register-yank

_evil-vi-delete(){ _evil-register-yank .vi-delete }

_evil-vi-delete-char(){ _evil-register-yank .vi-delete-char }

_evil-vi-kill-line(){ _evil-register-yank .vi-kill-line }

_evil-vi-kill-eol(){ _evil-register-yank .vi-kill-eol }

_evil-vi-change(){ _evil-register-yank .vi-change }

_evil-vi-change-eol(){ _evil-register-yank .vi-change-eol }

_evil-vi-change-whole-line(){ _evil-register-yank .vi-change-whole-line }

_evil-vi-yank(){ _evil-register-yank .vi-yank }

_evil-vi-yank-whole-line(){ _evil-register-yank .vi-yank-whole-line }

_evil-vi-yank-eol(){ _evil-register-yank .vi-yank-eol }

_evil-vi-put-after(){ _evil-register-paste .vi-put-after }

_evil-vi-put-before(){ _evil-register-paste .vi-put-before }
# }}}
# {{{ shadow vi-set-buffer
_evil-vi-set-buffer(){
	local v
	read -k 1 v
	case $v in
		''|[a-zA-Z0-9_])
			unset _evil_register
			zle .vi-set-buffer "$v"
		;;
		*) _evil_register="$v" ;;
	esac
}
# }}}
# {{{ register new widgets
for w in vi-delete vi-delete-char vi-kill-line vi-kill-eol \
	vi-change vi-change-eol vi-change-whole-line \
	vi-yank vi-yank-whole-line vi-yank-eol \
	vi-put-after vi-put-before vi-set-buffer
do
	# TODO: best practice?
	# overwrite old widgets
	zle -N "$w" "_evil-${w}"
done
# }}}
# vim:foldmethod=marker