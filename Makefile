all: docker-build docker-run-copy packagecloud

packagecloud: packagecloud-gems
	package_cloud push haf/oss/el/7 ./EventStore-3.1.0-1.x86_64.rpm

packagecloud-gems:
	bundle

docker-run-copy:
	docker run -v /home/core:/tmp/home --rm -it eventstore-build -c 'cp ../pkgbase/EventStore-3.1.0-1.x86_64.rpm ./share'

docker-build:
	docker build -t eventstore-build .