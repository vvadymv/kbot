VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: get format 
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -o kbot -v -ldflags "-X=github.com/vvadymv/kbot/cmd.appVersion=${VERSION}"

getversion:
	@echo Version: ${VERSION}

clean:
	rm -rf kbot