IMAGE_NAME := jjlin/gpac
IMAGE_TAG := latest

buildx:
	./buildx.sh $(IMAGE_NAME) $(IMAGE_TAG)

build:
	./build.sh $(IMAGE_NAME) $(IMAGE_TAG)
