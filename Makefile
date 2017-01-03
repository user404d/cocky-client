all: build/client build/games

build/client:
	@echo "Building client..."
	@raco make main.rkt

build/games:
	@echo "Building games..."
	@find games -path "*/main.rkt" | xargs raco make

clean:
	@find . -name compiled | xargs rm -r
