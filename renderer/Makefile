# renderer/Makefile
# Dynamical
# Matthew Jee
# mcjee@ucsc.edu

INCLUDEDEPS = ${filter clean,${MAKECMDGOALS}}

BUILD_PRODUCT   = mjrender.a

C_SOURCE        = matrix.cpp camera.cpp shader.cpp mesh.cpp renderable.cpp \
                  scene.cpp framebuffer.cpp texture.cpp transform.cpp
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
	@echo Cleaning Renderer ===================================================
	- rm $(OBJECTS) $(BUILD_PRODUCT)

dependencies:
	$(COMPILER) -MM $(C_SOURCE) > dependencies

ifeq "$(NEEDS_DEPENDENCIES)" ""
include dependencies
endif
