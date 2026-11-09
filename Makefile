TARGET := vitaminc
CXX := g++
GCOV ?= gcov-$(shell $(CXX) -dumpversion | cut -d. -f1)
CLANG_TIDY ?= clang-tidy
CXXFLAGS = -g3 -std=c++17 -Wall -MMD -Iinclude -I$(shell llvm-config-18 --includedir) -Werror
LDLIBS = -lfmt $(shell llvm-config-18 --libs core)
LEX = lex
# C++ features are used, yacc doesn't suffice
YACC = bison
YFLAGS = --verbose --debug -Wcounterexamples -Wall
PARSER_DIR := src/frontend/parser
PARSER_CPP := $(PARSER_DIR)/y.tab.cpp
PARSER_HPP := include/frontend/y.tab.hpp
LEX_CPP := $(PARSER_DIR)/lex.yy.cpp
COVERAGE_DIR = $(CURDIR)/.coverage
GCOVFLAGS = -fprofile-arcs -ftest-coverage

# The Flex or Bison-generated files are not included.
SRC := $(filter-out $(PARSER_CPP) $(LEX_CPP),$(shell find src/ -name "*.cpp")) main.cpp
INC := $(filter-out $(PARSER_HPP),$(shell find include/ -name "*.hpp"))

OBJS := $(SRC:.cpp=.o) $(PARSER_CPP:.cpp=.o) $(LEX_CPP:.cpp=.o)
DEPS = $(OBJS:.o=.d)

.PHONY: all clean test tidy coverage coverage-report

all: $(TARGET)

test: $(TARGET)
	$(MAKE) -C test/ test-all
	@echo "NOTE: If you want to run individual tests, check 'test/Makefile'."

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@ $(LDLIBS)

$(LEX_CPP): $(PARSER_DIR)/lexer.l $(PARSER_HPP)
	$(LEX) -o $@ $<

$(PARSER_HPP): $(PARSER_CPP)
$(PARSER_CPP): $(PARSER_DIR)/parser.y
	$(YACC) $(YFLAGS) --defines=$(PARSER_HPP) $< -o $@

#
# Please note that although we're handling dependencies automatically with -MMD,
# files that includes Flex or Bison-generated files still have to make such
# dependency explicit to enforce the ordering.
#

main.o: %.o: %.cpp $(PARSER_HPP)

$(PARSER_CPP:.cpp=.o): CXXFLAGS += -Iinclude/frontend

# Since y.tab.hpp is included by the source files, it must exist;
# otherwise, a clang-diagnostic-error will be raised.

tidy: $(PARSER_HPP)
	$(CLANG_TIDY) $(CLANG_TIDY_FLAGS) -p . $(SRC) $(INC) -- $(CXXFLAGS)

#
# Using Gcov to collect coverage data and Lcov to generate HTML report.
#

coverage: CXXFLAGS += -O0 $(GCOVFLAGS)
# You might want to run coverage-report instead of coverage if you have lcov installed.
coverage: clean $(TARGET) # Make a clean build to use the coverage flags.
	@echo "[INFO] Checking if gcov is installed..."
	@command -v $(GCOV) >/dev/null 2>&1 \
		|| { echo >&2 "gcov is not installed, consider installing it first"; exit 1; }
	@echo "[INFO] Running tests..."
	@$(MAKE) test
	@echo "[INFO] Generating coverage data..."
	@$(GCOV) $(OBJS:.o=.cpp)
	@echo "[INFO] Coverage data generated."
	@echo "[INFO] Removing the executable since it's not meant to be used..."
	@$(RM) $(TARGET)

coverage-report: coverage
	@echo "[INFO] Checking if lcov is installed..."
	@command -v lcov >/dev/null 2>&1 \
		|| { echo >&2 "lcov is not installed, consider installing it first"; exit 1; }
	@# genhtml is part of lcov; no need to check for it.
	@echo "[INFO] Creating coverage directory..."
	@mkdir -p $(COVERAGE_DIR)
	@echo "[INFO] Generating coverage info..."
	@lcov --gcov-tool $(GCOV) --capture --directory $(CURDIR) \
		--exclude "/usr/include/*" --exclude "/usr/local/include/*" \
		--exclude "/usr/lib/llvm-*/include/*" \
		--exclude "**/lex.yy.*" --exclude "**/y.tab.*" \
		--output-file $(COVERAGE_DIR)/coverage.info
	@echo "[INFO] Generating HTML report..."
	@genhtml $(COVERAGE_DIR)/coverage.info --output-directory $(COVERAGE_DIR)
	@echo "Open $(COVERAGE_DIR)/index.html in your browser to view the coverage report."

clean:
	$(RM) -r $(TARGET) $(OBJS) $(DEPS) \
		$(PARSER_CPP) $(PARSER_HPP) $(LEX_CPP) \
		$(PARSER_DIR)/y.output \
		$(OBJS:.o=.gcda) $(OBJS:.o=.gcno) *.gcov $(COVERAGE_DIR)
	$(MAKE) -C test/ clean

-include $(DEPS)
