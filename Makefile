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
