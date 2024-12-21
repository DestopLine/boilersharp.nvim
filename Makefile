test: deps/mini.test deps/parser/xml.so
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

deps/mini.test:
	@mkdir -p deps
	git submodule update --init --recursive

deps/parser/xml.so:
	@mkdir -p deps/parser
	nvim -c "luafile scripts/fetch_xml_parser.lua" -c "q" --headless
