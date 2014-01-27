# Makefile
# Dynamical
# Matthew Jee
# mcjee@ucsc.edu

OBJECT_DIR      = objects
BUILD_DIR       = build
LIB_DIR         = lib
BUILD_NAME      = dynamical
BUILD_PRODUCT   = $(BUILD_DIR)/$(BUILD_NAME)

C_SOURCE        = main.cpp
STATIC_LIBS     = libglfw3.a
FRAMEWORKS      = Cocoa OpenGL IOKit CoreVideo
OBJECTS         = $(C_SOURCE:%.cpp=$(OBJECT_DIR)/%.o)

COMPILER        = clang++
COMPILE_OPTIONS = -Wall -Wextra 
LINK_OPTIONS    = -Wall -Wextra $(FRAMEWORKS:%=-framework %)

COMPILE_CMD = $(COMPILER) $(COMPILE_OPTIONS)
LINK_CMD    = $(COMPILER) $(LINK_OPTIONS)

all: $(BUILD_PRODUCT)

$(BUILD_PRODUCT): $(OBJECTS)
	$(LINK_CMD) -o $@ $(OBJECTS) $(STATIC_LIBS:%=$(LIB_DIR)/%)

$(OBJECT_DIR)/%.o: %.cpp
	$(COMPILE_CMD) -o $@ -c $<

clean:
	- rm $(OBJECTS) $(BUILD_PRODUCT)
