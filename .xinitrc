[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

xinput set-prop 14 299 1 &
sh ~/.fehbg &
unclutter &
picom &
i3
