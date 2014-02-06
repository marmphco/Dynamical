# Makefile
# Dynamical
# Matthew Jee
# mcjee@ucsc.edu

INCLUDEDEPS = ${filter clean,${MAKECMDGOALS}}

OBJECT_DIR      = objects
BUILD_DIR       = build
LIB_DIR         = lib
BUILD_NAME      = dynamical
BUILD_PRODUCT   = $(BUILD_DIR)/$(BUILD_NAME)
BUNDLE          = $(BUILD_DIR)/$(BUILD_NAME).app

C_SOURCE        = main.cpp parameter.cpp dynamical.cpp integrator.cpp\
                  matrix.cpp camera.cpp shader.cpp mesh.cpp renderable.cpp \
                  scene.cpp framebuffer.cpp texture.cpp
STATIC_LIBS     = libglfw3.a
FRAMEWORKS      = Cocoa OpenGL IOKit CoreVideo
OBJECTS         = $(C_SOURCE:%.cpp=$(OBJECT_DIR)/%.o)

COMPILER        = clang++
COMPILE_OPTIONS = -Wall -Wextra -pedantic
LINK_OPTIONS    = -Wall -Wextra $(FRAMEWORKS:%=-framework %)

COMPILE_CMD = $(COMPILER) $(COMPILE_OPTIONS)
LINK_CMD    = $(COMPILER) $(LINK_OPTIONS)

all: $(BUILD_PRODUCT)

again: clean $(BUILD_PRODUCT)

run: $(BUILD_PRODUCT)
	cp -r shaders/ $(BUILD_DIR)/shaders/
	./$(BUILD_PRODUCT)

bundle: $(BUNDLE)

$(BUNDLE): $(BUILD_PRODUCT)
	mkdir $(BUNDLE)
	mkdir $(BUNDLE)/Contents
	mkdir $(BUNDLE)/Contents/MacOS
	mkdir $(BUNDLE)/Contents/Resources
	mkdir $(BUNDLE)/Contents/Resources/shaders
	cp shaders/* $(BUNDLE)/Contents/Resources/shaders/
	cp $(BUILD_PRODUCT) $(BUNDLE)/Contents/MacOS

runbundle: $(BUNDLE)
	open $(BUNDLE)

$(BUILD_PRODUCT): $(OBJECTS)
	$(LINK_CMD) -o $@ $(OBJECTS) $(STATIC_LIBS:%=$(LIB_DIR)/%)

$(OBJECT_DIR)/%.o: %.cpp
	$(COMPILE_CMD) -o $@ -c $<

clean:
	- rm $(OBJECTS) $(BUILD_PRODUCT) $(BUNDLE)
	- rm $(BUILD_DIR)/shaders/*

dependencies:
	$(COMPILER) -MM $(C_SOURCE) > dependencies

ifeq "$(NEEDS_DEPENDENCIES)" ""
include dependencies
endif
