all: docker-build docker-run-copy packagecloud

packagecloud: packagecloud-gems
	package_cloud push haf/oss/el/7 ./eventstore-3.1.0-4.x86_64.rpm

packagecloud-gems:
	bundle

docker-run-copy:
	ID=$(shell docker create eventstore-3.1.0-4)
	docker cp $(ID):/tmp/pkgbase/eventstore-3.1.0-4.x86_64.rpm - > eventstore-3.1.0-4.x86_64.rpm
	docker rm -v $(ID)

docker-build:
	docker build -t eventstore-build .
