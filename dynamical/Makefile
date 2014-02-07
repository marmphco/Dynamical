# dynamical/Makefile
# Dynamical
# Matthew Jee
# mcjee@ucsc.edu

INCLUDEDEPS = ${filter clean,${MAKECMDGOALS}}

BUILD_PRODUCT   = dynamical.a

C_SOURCE        = parameter.cpp dynamical.cpp integrator.cpp
OBJECTS         = $(C_SOURCE:%.cpp=%.o)

COMPILER        = clang++
COMPILE_OPTIONS = -Wall -Wextra -pedantic

COMPILE_CMD = $(COMPILER) $(COMPILE_OPTIONS)

all: $(BUILD_PRODUCT)

run: $(BUILD_PRODUCT)
	cp -r shaders/ $(BUILD_DIR)/shaders/
	./$(BUILD_PRODUCT)

$(BUILD_PRODUCT): $(OBJECTS)
	@echo Archiving Library ===================================================
	ar -rs $(BUILD_PRODUCT) $(OBJECTS)

%.o: %.cpp
	$(COMPILE_CMD) -o $@ -c $<

clean:
	@echo Cleaning Dynamical ==================================================
	- rm $(OBJECTS) $(BUILD_PRODUCT)

dependencies:
	$(COMPILER) -MM $(C_SOURCE) > dependencies

ifeq "$(NEEDS_DEPENDENCIES)" ""
include dependencies
endif
