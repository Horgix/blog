all::
	hugo

withdocker::
	docker run -it --rm \
	  -v $(shell pwd):/src \
	  -w /src \
	  horgix/hugo:0.37.1

index::
	npm run index

clean::
	rm -rf public/
