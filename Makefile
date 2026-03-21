CONFDIR         = $(HOME)/.config/nvim
INCLUDE_TARGETS = $(patsubst include/Makefile-%,%,$(wildcard include/Makefile-*))
MAKEFLAGS      += --no-print-directory

.PHONY: help install vimrc pull git diff $(INCLUDE_TARGETS)

info help:
	@echo "make install    install shell and Vim configuration"
	@for t in $(INCLUDE_TARGETS); do \
		$(MAKE) -f include/Makefile-$$t info; \
	done

install: shell vimrc

vimrc:
	ln -sf $(CONFDIR)/vimrc.vim $(HOME)/.vimrc

$(INCLUDE_TARGETS):
	$(MAKE) -f include/Makefile-$@ $@

pull:
	git pull --ff-only $(ARGS)

git:
	git $(ARGS)
