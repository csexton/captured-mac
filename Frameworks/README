Frameworks
==========

Captured needs a couple of external frameworks, I have included the binaries here -- along with steps on how to build them.

Curl
====

To build the curl framework, with ssh support:

Download from here: http://www.opensource.apple.com/source/curl/curl-57.2/

I also have a mirror here: https://github.com/csexton/curl-7.19.7

Install libssh2 from homebrew, I used v 1.2.7.

    brew install libssh2

Compile curl using apple's script

    cd curl-1.19.7
    ./MacOSX-Framework

Since that script calls ./configure, it should discover libssh2 and build in support. You can verify with `otool -L`

Copy libssh2 into the framework bundle  and fix it's load paths

    cp /usr/local/lib/libssh2.1.dylib libcurl.framework/Versions/A/
    install_name_tool -change /usr/local/lib/libssh2.1.dylib @loader_path/libssh2.1.dylib libcurl.framework/Versions/A/libcurl
    otool -L libcurl.framework/Versions/A/libcurl
    #libcurl.framework/Versions/A/libcurl:
    #        @executable_path/../Frameworks/libcurl.framework/Versions/A/libcurl (compatibility version 6.0.0, current version 6.1.0)
    #        @loader_path/libssh2.1.dylib (compatibility version 2.0.0, current version 2.1.0)
    #        /usr/lib/libssl.0.9.8.dylib (compatibility version 0.9.8, current version 0.9.8)
    #        /usr/lib/libcrypto.0.9.8.dylib (compatibility version 0.9.8, current version 0.9.8)
    #        /System/Library/Frameworks/LDAP.framework/Versions/A/LDAP (compatibility version 1.0.0, current version 2.2.0)
    #        /System/Library/Frameworks/Kerberos.framework/Versions/A/Kerberos (compatibility version 5.0.0, current version 5.0.0)
    #        /usr/lib/libresolv.9.dylib (compatibility version 1.0.0, current version 41.0.0)
    #        /usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.3)
    #        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 125.2.0)

Fix load paths

    install_name_tool -change /usr/local/lib/libssh2.1.dylib @loader_path/libssh2.1.dylib ./libcurl
    install_name_tool -id @executable_path/../Frameworks/libcurl.framework/Versions/A/libssh2.1.dylib ./libssh2.1.dylib

Make sure not to cp that framework around, since it will expand the symlinks, just move it where you want it.

Growl
=====

Download the growl sdk from growl.info and copy the Growl.framework out of the disk image. You will have to remove the ppc archetecture or binary will be rejected from the App Store.

Removing ppc Arch
-----------------

    lipo -remove ppc Growl.framework/Growl -output Growl.framework/GrowlIntel

Code Signing
============

    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./libcurl.framework/Versions/A/libcurl
    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./libcurl.framework/Versions/A/libssh2.1.dylib
    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./Growl.framework/Versions/A/Growl
    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./GData.framework/Versions/A/GData

http://developer.apple.com/library/mac/#technotes/tn2206/_index.html Says to do the above here:

Signing Frameworks
------------------
Seeing as frameworks are bundles it would seem logical to conclude that you can sign a framework directly. However, this is not the case. To avoid problems when signing frameworks make sure that you sign a specific version as opposed to the whole framework:

    $admin> # This is the wrong way:
    $admin> codesign -s my-signing-identity ../FooBarBaz.framework
    $admin> # This is the right way:
    $admin> codesign -s my-signing-identity ../FooBarBaz.framework/Versions/A

So maybe this will help:

    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./libcurl.framework
    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./Growl.framework
    codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" ./GData.framework
