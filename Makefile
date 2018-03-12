all::
	hugo

withdocker::
	docker run -it --rm \
	  -v $(shell pwd):/src \
	  -w /src \
	  horgix/hugo:0.37.1

index::
	npm run index

deploy::
	curl -L -X \
	  PUT "https://marathon.horgix.eu/v2/apps/blog" \
	  -H "Content-type: application/json" \
	  -d @marathon_app.json \
	  -u "${MARATHON_USERNAME}:${MARATHON_PASSWORD}"

clean::
	rm -rf public/
