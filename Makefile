.PHONY: install
install: qtile

.PHONY: qtile
qtile:
	cp -r ~/.config/qtile ~/backqtile
	cp -r qtile ~/.config
	qtile check
