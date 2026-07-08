
# Autostart applications
## Polybar or tint
~/.config/i3/polybar/polybar-i3 &


lxpolkit &
~/.local/bin/greenclip daemon &
xsettingsd &
dunst -config ~/.config/i3/dunst/dunstrc &
# picom --config ~/.config/i3/picom/picom.conf -b &
feh --bg-fill /home/anurag/.config/i3/wallpaper/nord_mountains.png &

# sxhkd
pkill -x sxhkd
sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &

# First-login welcome (shown once, dismissable)
if [ ! -f "$HOME/.cache/i3/welcomed" ]; then
	mkdir -p "$HOME/.cache/i3"
	touch "$HOME/.cache/i3/welcomed"
	(sleep 3; notify-send -u normal -t 15000 \
		"Welcome to i3" \
		"Press Super + / anytime to see all keybindings.&#10;See ~/QUICKSTART-i3.md for a cheat sheet.") &
fi
