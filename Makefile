# Auto-LFS-Builder top-level Makefile

.PHONY: all parse generate validate

all: parse generate validate

parse:
	@./scripts/run_parser.sh

generate:
	@./scripts/generate_scripts.sh

validate:
	@./scripts/validate.sh

