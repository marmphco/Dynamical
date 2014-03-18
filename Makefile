# This should build the entire project, and place the
# Mac .app bundle in the OSX/build/Release directory.
# 
# This Makefile requires that you:
#   - are running OS X
#   - installed Xcode + Command line tools
#

all:
	cd dynamical; make;
	cd renderer; make;
	cd OSX; xcodebuild;
	cp -r OSX/build/Release/Dynamical.app .

