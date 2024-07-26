VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
APP=$(shell basename $(shell git remote get-url origin) | sed 's/\.git$$//')
REGISTRY=vadymv
#TARGETARCH=arm64
TARGETARCH=amd64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: get format 
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o kbot -v -ldflags "-X=github.com/vvadymv/kbot/cmd.appVersion=${VERSION}"

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

getversion:
	@echo Version: ${VERSION}
	@echo APP: ${APP}

clean:
	rm -rf kbot
	docker image rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -o kbot -v -ldflags "-X=github.com/vvadymv/kbot/cmd.appVersion=${VERSION}"

arm:
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -o kbot -v -ldflags "-X=github.com/vvadymv/kbot/cmd.appVersion=${VERSION}"