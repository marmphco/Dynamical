# Makefile
# Dynamical
# Matthew Jee
# mcjee@ucsc.edu

INCLUDEDEPS = ${filter clean,${MAKECMDGOALS}}

OBJECT_DIR      = objects
BUILD_DIR       = build
BUILD_NAME      = dynamical
BUILD_PRODUCT   = $(BUILD_DIR)/$(BUILD_NAME)
BUNDLE          = $(BUILD_DIR)/$(BUILD_NAME).app

C_SOURCE        = main.cpp
STATIC_LIBS     = lib/libglfw3.a renderer/mjrender.a dynamical/dynamical.a
FRAMEWORKS      = Cocoa OpenGL IOKit CoreVideo
OBJECTS         = $(C_SOURCE:%.cpp=$(OBJECT_DIR)/%.o)

COMPILER        = clang++
COMPILE_OPTIONS = -Wall -Wextra -pedantic
LINK_OPTIONS    = -Wall -Wextra $(FRAMEWORKS:%=-framework %)

COMPILE_CMD = $(COMPILER) $(COMPILE_OPTIONS)
LINK_CMD    = $(COMPILER) $(LINK_OPTIONS)

all: $(BUILD_PRODUCT)
	@echo Building All ========================================================

again: clean $(BUILD_PRODUCT)

renderer/mjrender.a:
	@echo Building Renderer ===================================================
	make -C renderer

dynamical/dynamical.a:
	@echo Building Dynamical ==================================================
	make -C dynamical

run: $(BUILD_PRODUCT)
	@echo Running =============================================================
	cp -r shaders/ $(BUILD_DIR)/shaders/
	./$(BUILD_PRODUCT)

bundle: $(BUNDLE)

$(BUNDLE): $(BUILD_PRODUCT)
	@echo Building Bundle =====================================================
	mkdir $(BUNDLE)
	mkdir $(BUNDLE)/Contents
	mkdir $(BUNDLE)/Contents/MacOS
	mkdir $(BUNDLE)/Contents/Resources
	mkdir $(BUNDLE)/Contents/Resources/shaders
	cp shaders/* $(BUNDLE)/Contents/Resources/shaders/
	cp $(BUILD_PRODUCT) $(BUNDLE)/Contents/MacOS

runbundle: $(BUNDLE)
	open $(BUNDLE)

$(BUILD_PRODUCT): $(OBJECTS) $(STATIC_LIBS)
	@echo Linking =============================================================
	$(LINK_CMD) -o $@ $(OBJECTS) $(STATIC_LIBS)

$(OBJECT_DIR)/%.o: %.cpp
	$(COMPILE_CMD) -o $@ -c $<

clean:
	@echo Cleaning ============================================================
	- rm $(OBJECTS) $(BUILD_PRODUCT) 
	- rm -r $(BUNDLE)
	- rm $(BUILD_DIR)/shaders/*
	- make -C renderer clean
	- make -C dynamical clean

dependencies:
	@echo Building Dependencies ===============================================
	$(COMPILER) -MM $(C_SOURCE) > dependencies

ifeq "$(NEEDS_DEPENDENCIES)" ""
include dependencies
endif
