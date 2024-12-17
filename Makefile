test: deps
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

deps:
	@mkdir -p deps
	git submodule update --init --recursive
