# renderer/Makefile
# Dynamical
# Matthew Jee
# mcjee@ucsc.edu

INCLUDEDEPS = ${filter clean,${MAKECMDGOALS}}

BUILD_PRODUCT   = mjrender.a

C_SOURCE        = matrix.cpp camera.cpp shader.cpp mesh.cpp renderable.cpp \
                  scene.cpp framebuffer.cpp texture.cpp
FRAMEWORKS      = Cocoa OpenGL IOKit CoreVideo
OBJECTS         = $(C_SOURCE:%.cpp=%.o)

COMPILER        = clang++
COMPILE_OPTIONS = -Wall -Wextra -pedantic
LINK_OPTIONS    = -Wall -Wextra $(FRAMEWORKS:%=-framework %)

COMPILE_CMD = $(COMPILER) $(COMPILE_OPTIONS)
LINK_CMD    = $(COMPILER) $(LINK_OPTIONS)

all: $(BUILD_PRODUCT)

run: $(BUILD_PRODUCT)
	cp -r shaders/ $(BUILD_DIR)/shaders/
	./$(BUILD_PRODUCT)

bundle: $(BUNDLE)

$(BUILD_PRODUCT): $(OBJECTS)
	# $(LINK_CMD) -o $@ $(OBJECTS)
	# archive into library
	ar -rs $(BUILD_PRODUCT) $(OBJECTS)

%.o: %.cpp
	$(COMPILE_CMD) -o $@ -c $<

clean:
	- rm $(OBJECTS) $(BUILD_PRODUCT)

dependencies:
	$(COMPILER) -MM $(C_SOURCE) > dependencies

ifeq "$(NEEDS_DEPENDENCIES)" ""
include dependencies
endif
