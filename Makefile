.PHONY: install
install: qtile

.PHONY: qtile
qtile:
	cp -r ~/.config/qtile ~/backup
	cp -r qtile ~/.config
	qtile check

.PHONY: picom
picom:
	cp -r ~/.config/picom ~/backup
	cp -r picom ~/.config

.PHONY: rofi
rofi:
	cp -r ~/.config/rofi ~/backup
	cp -r rofi ~/.config
