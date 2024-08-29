VERSION_TAG= $(shell git describe --tags 2>/dev/null || echo 'v0.0.0')

.PHONY: image
image:
	@echo "VERSION_TAG:${VERSION_TAG}"
	@docker build -f Dockerfile -t registry.cn-sh-01.sensecore.cn/tsm_2024052501/kernel-math-py:${VERSION_TAG} .
