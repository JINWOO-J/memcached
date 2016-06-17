REPO = dr.ytlabs.co.kr
REPO_HUB = jinwoo
NAME = memcached
VERSION = 1.4.25
include ENVAR

.PHONY: all build push test tag_latest release ssh bash

all: build push

build:
	cat .Dockerfile | sed  "s/__MEMCACHED_VERSION__/$(VERSION)/g"   > Dockerfile
	docker build --no-cache --rm=true --build-arg MEMCACHED_VERSION=$(VERSION) -t $(NAME):$(VERSION) .

push:
	docker tag -f $(NAME):$(VERSION) $(REPO)/$(NAME):$(VERSION)
	docker push $(REPO)/$(NAME):$(VERSION)

push_hub:
	docker tag -f $(NAME):$(VERSION) $(REPO_HUB)/$(NAME):$(VERSION)
	docker push $(REPO_HUB)/$(NAME):$(VERSION)

build_hub:
	echo "TRIGGER_KEY" ${TRIGGERKEY}
	cat .Dockerfile | sed  "s/__MEMCACHED_VERSION__/$(VERSION)/g"   > Dockerfile
	git add .
	git commit -m "$(NAME):$(VERSION) by Makefile"
	git push
	git tag -a "$(VERSION)" -m "$(VERSION) by Makefile"
	git push origin --tags
	curl -H "Content-Type: application/json" --data '{"source_type": "Tag", "source_name": "$(VERSION)"}' -X POST https://registry.hub.docker.com/u/jinwoo/${NAME}/trigger/${TRIGGERKEY}/


bash:
	docker run --entrypoint="bash" --rm -it $(NAME):$(VERSION)

tag_latest:
	docker tag -f $(REPO)/$(NAME):$(VERSION) $(REPO)/$(NAME):latest
	docker push $(REPO)/$(NAME):latest

test:
	docker run --rm -it $(NAME):$(VERSION)


init:
	git init
	git add .
	git commit -m "first commit"
	git remote add origin git@github.com:JINWOO-J/$(NAME).git
	git push -u origin master
