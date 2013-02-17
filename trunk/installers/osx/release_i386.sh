#!/bin/sh

# Need Xcode 3.2.6 or later (pkgbuild and productbuild)
# 1. install python (and wxpython) 2.6 and 2.7 (32-bit)
# 2. update pyo sources
# 3. compile and install pyo float and double
# 4. cd utils and build E-Pyo
# 5. cd installer/osx and build the realease

export PACKAGE_NAME=pyo_0.6.4_i386.pkg
export DMG_DIR="pyo 0.6.4 Intel"
export DMG_NAME="pyo_0.6.4_OSX-Intel.dmg"
export INSTALLER_DIR=`pwd`/installer
export PYO_MODULE_DIR=$INSTALLER_DIR/PyoModule/Package_Contents/tmp
export SUPPORT_LIBS_DIR=$INSTALLER_DIR/SupportLibs/Package_Contents/usr/local/lib
export BUILD_RESOURCES=$INSTALLER_DIR/PkgResources/English.lproj
export PKG_RESOURCES=$INSTALLER_DIR/../PkgResources_i386

mkdir -p $PYO_MODULE_DIR
mkdir -p $SUPPORT_LIBS_DIR
mkdir -p $BUILD_RESOURCES

cp $PKG_RESOURCES/License.rtf $BUILD_RESOURCES/License.rtf
cp $PKG_RESOURCES/Welcome.rtf $BUILD_RESOURCES/Welcome.rtf
cp $PKG_RESOURCES/ReadMe.rtf $BUILD_RESOURCES/ReadMe.rtf

svn export ../.. installer/pyo-build
cd installer/pyo-build

echo "building pyo for python 2.6 (32-bit)..."
sudo /usr/local/bin/python2.6 setup.py install --use-coreaudio --use-double

sudo cp -R build/lib.macosx-10.3-fat-2.6 $PYO_MODULE_DIR/python26

echo "building pyo for python 2.7 (32-bit)..."
sudo /usr/local/bin/python2.7 setup.py install --use-coreaudio --use-double

sudo cp -R build/lib.macosx-10.3-fat-2.7 $PYO_MODULE_DIR/python27

cd ..

echo "copying support libs..."
sudo cp /usr/local/lib/liblo.0.dylib $SUPPORT_LIBS_DIR/liblo.0.dylib
sudo cp /usr/local/lib/libportaudio.2.dylib $SUPPORT_LIBS_DIR/libportaudio.2.dylib
sudo cp /usr/local/lib/libportmidi.dylib $SUPPORT_LIBS_DIR/libportmidi.dylib
sudo cp /usr/local/lib/libsndfile.1.dylib $SUPPORT_LIBS_DIR/libsndfile.1.dylib

echo "setting permissions..."

sudo chgrp -R admin PyoModule/Package_Contents/tmp
sudo chown -R root PyoModule/Package_Contents/tmp
sudo chmod -R 755 PyoModule/Package_Contents/tmp

sudo chgrp -R wheel SupportLibs/Package_Contents/usr
sudo chown -R root SupportLibs/Package_Contents/usr
sudo chmod -R 755 SupportLibs/Package_Contents/usr

echo "building packages..."

pkgbuild    --identifier com.iact.umontreal.ca.pyo.tmp.pkg \
            --root PyoModule/Package_Contents/ \
            --version 1.0 \
            --scripts $PKG_RESOURCES \
            PyoModule.pkg

pkgbuild    --identifier com.iact.umontreal.ca.pyo.usr.pkg \
            --root SupportLibs/Package_Contents/ \
            --version 1.0 \
            SupportLibs.pkg

echo "building product..."
productbuild --distribution ../Distribution.dist --resources $BUILD_RESOURCES $PACKAGE_NAME

echo "assembling DMG..."
mkdir "$DMG_DIR"
cd "$DMG_DIR"
cp ../$PACKAGE_NAME .
cp -R ../../../../utils/E-Pyo.app .
ln -s /Applications .
cd ..

hdiutil create "$DMG_NAME" -srcfolder "$DMG_DIR"

cd ..
mv installer/$DMG_NAME .

echo "clean up resources..."
sudo rm -rf installer


