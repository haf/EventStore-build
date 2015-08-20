all: build push

NAME=eventstore-3.1.0-4
PKG=$(NAME).x86_64.rpm

push: push-gems artifacts
	package_cloud push haf/oss/el/7 ./$(PKG)

push-gems:
	bundle

artifacts:
	ID=$(shell docker create $(NAME))
	PWD=$(shell pwd)
	docker run -v $(PWD):/tmp/share --rm $(NAME) "-c" 'cp /tmp/pkgbase/$(PKG) /tmp/share'
	docker run -v $(PWD):/tmp/share --rm $(NAME) "-c" 'cp /tmp/pkgbase/Unaligner.tar.gz /tmp/share/Unaligner.tar.gz'

build:
	docker build -t $(NAME) .
