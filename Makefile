.PHONY: all test format

all:
	mix compile

test:
	# npm run --prefix assets/ flow
	mix dialyzer
	# mix test

format:
	mix format
