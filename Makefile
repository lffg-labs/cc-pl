CC := clang++
CCFLAGS := -std=c++2a -Wall -Wextra -Wpedantic

CCF := $(CC) $(CCFLAGS)

SRC := src
SRCS := $(patsubst $(SRC)/%,%,$(wildcard src/*))

TARGET := target

# ensure target directories are created
$(shell mkdir -p $(TARGET))

# object libraries
.PRECIOUS: $(TARGET)/%.o
$(TARGET)/%.o: $(SRC)/%/lib.cc $(TARGET_OBJ)
	$(CCF) -c -o $@ $<

# main executables
$(TARGET)/%: $(TARGET)/%.o $(SRC)/%/main.cc
	$(CCF) -o $@ $^

# test executables
$(TARGET)/%-test: $(TARGET)/%.o $(SRC)/%/test.cc
	$(CCF) -o $@ $^

# run-% utility
RUN_TARGETS := $(patsubst %,run-%,$(SRCS))
.PHONY: $(RUN_TARGETS)
$(RUN_TARGETS): run-%: $(TARGET)/%
	./$<

# test-% utility
TEST_TARGETS := $(patsubst %,test-%,$(SRCS))
.PHONY: $(TEST_TARGETS)
$(TEST_TARGETS): test-%: $(TARGET)/%-test
	./$<

.PHONY: clear
clean:
	rm -rf target

.PHONY: new
new:
ifeq ($(NAME),)
	@echo 'error: missing `NAME` variable; e.g. `make new NAME="foo"`'
else
	cp -r src/plus src/$(NAME)
endif

.PHONY: show-targets
show-targets:
	@echo '$(SRCS)'
