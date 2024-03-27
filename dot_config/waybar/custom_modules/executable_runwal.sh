wallust $(cat /home/dani/.config/waypaper/config.ini | grep -Po 'wallpaper\s*=\s*\K\S+')

pkill waybar
waybar

#Keyboard vVv
~/.config/waybar/generated-kbd-color.txt
rgb_keyboard --brightness 9 \
--leds hurricane \
--color $(cat ~/.config/waybar/generated-kbd-color.txt) \
--speed 0 \
--direction left \
--profile 1