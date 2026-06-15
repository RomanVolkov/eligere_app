.PHONY: bump build release test clean

bump:
	@if [ -z "$(V)" ] || [ -z "$(B)" ]; then \
		echo "Usage: make bump V=<version> B=<build>"; \
		echo "Example: make bump V=2.3.0 B=35"; \
		exit 1; \
	fi
	./scripts/bump-version.sh $(V) $(B)

build:
	./scripts/build_dmg.sh

release:
	./scripts/release.sh

test:
	cd EligereTests && swift test

clean:
	rm -rf output/ build/
