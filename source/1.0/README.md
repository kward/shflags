====================
shFlags 1.0.x README
====================

GitHub
======

This project is stored on GitHub as https://github.com/kward/shflags.
Documentation is available there, as are all releases and source code. The
source code is stored in Git and can be accessed using the following
information.

Browse the code in a web browser at https://github.com/kward/shflags.

Check out the code locally

```sh
$ git clone https://github.com/kward/shflags.git
```

Documentation is (still) available on the web at
https://github.com/kward/shflags/wiki/Documentation10x


Making a release
================

For these steps, it is assumed we are working with release 1.0.0.

Steps:

- Write release notes.
- Update version.
- Finish change log.
- Check all the code in.
- Tag the release.
- Export the release.
- Create tarball.
- Create hashes for the tarball and sign with `gpg`.
- Update website.

Write Release Notes
-------------------

This should be pretty self explanatory. Use one of the release notes from a
previous release as an example.

Update Version
--------------

Edit `src/shflags` and change the version number in the `FLAGS_VERSION`
variable.

Finish Documentation
--------------------

Make sure that any remaining changes get put into the `CHANGES-X.X.txt` file.

Finish writing the `RELEASE_NOTES-X.X.X.txt`. Once it is finished, run it
through the `fmt` command to make it pretty. (This assumes the lines weren't
already wrapped at 80 chars when the file was edited.)

```sh
$ fmt -w 80 RELEASE_NOTES-2.0.0.txt >RELEASE_NOTES-2.0.0.txt.new
$ mv RELEASE_NOTES-2.0.0.txt.new RELEASE_NOTES-2.0.0.txt
```

We want to have an up-to-date version of the documentation in the release, so
we'd better build it.

```sh
$ pwd
.../shflags/source/1.0
$ rst2html --stylesheet-path=doc/rst2html.css README.txt >README.html
```

Check In All the Code
---------------------

This step is pretty self-explainatory

```sh
$ pwd
.../shflags/source/1.0
$ svn ci -m "finalizing 1.0.0 release"
```

Tag the Release
---------------

```sh
$ cd ..
$ pwd
.../shflags/source
$ ls
1.0
$ svn cp -m "Release 1.0.0" 1.0 https://shflags.googlecode.com/svn/tags/1.0.0
```

Export the Release
------------------

```sh
$ cd ../builds
$ pwd
.../shflags/builds
$ svn export https://shflags.googlecode.com/svn/tags/1.0.0 shflags-1.0.0
```

Create the tarball
------------------

```sh
$ tar cfz ../releases/shflags-1.0.0.tgz shflags-1.0.0
```

Sign the tarball with gpg
-------------------------

```sh
$ cd ../releases
$ gpg --default-key kate.ward@forestent.com --detach-sign shflags-1.0.0.tgz
```

Post the release
----------------

To post the release, the ProjectInfo page needs to be updated with the release
info (release, date, and MD5), and the release with GPG signature needs to
uploaded.


Appendix
========

Related Documentation
---------------------

google-gflags (http://code.google.com/p/google-gflags/)

Miscellaneous
-------------

This document is written using the Restructured Text format to make it easily
parsable into an HTML file.
