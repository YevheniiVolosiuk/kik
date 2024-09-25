#!/usr/bin/env bash

#gum_style "$COLOR_HELP" "My test gum text"

#gum_confirm "Do you like kik tool?"

#echo "Pick a card, any card..."
#CARD=$(gum_choose --height 15 {{A,K,Q,J},{10..2}}" "{♠,♥,♣,♦})
#echo "Was your card the $(gum_style "$COLOR_ACCENT" "$CARD")?"

#user_input=$(gum_input "*" --cursor.foreground "#FF0" \
#                       --prompt.foreground "#0FF" \
#                       --placeholder "What's up?" \
#                       --width 80 \
#                       --value "Not much, hby?")

#echo "You said: $user_input"

gum_spin "It must spin" "sleep 10"
gum spin --spinner dot --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner line --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner minidot --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner jump --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner pulse --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner points --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner globe --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner moon --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner monkey --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner meter --title "IT WILL SPIN" -- "sleep 10"
gum spin --spinner hamburger --title "IT WILL SPIN" -- "sleep 10"
