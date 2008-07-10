====================
shFlags 1.0.x README
====================

code.google.com
===============

This project is stored on code.google.com as http://code.google.com/p/shflags/.
Documentation is available there, as are all releases and source code. The
source code is stored in Subversion and can be accessed using the following
information.

Browse the code in a web browser:

- http://code.google.com/p/shflags/source/browse
- svn > trunk > source > 1.0

Check out the code locally ::

  $ svn checkout http://shflags.googlecode.com/svn/trunk/ shflags-read-only

Documentation is available on the web at
http://code.google.com/p/shflags/wiki/Documentation10x.


Making a release
================

For these steps, it is assumed we are working with release 1.0.0.

Steps:

- write release notes
- update version
- finish changelog
- check all the code in
- tag the release
- export the release
- create tarball
- md5sum the tarball and sign with gpg
- update website
- post to code.google.com and Freshmeat

Write Release Notes
-------------------

This should be pretty self explainatory. Use one of the release notes from a
previous release as an example.

To get the versions of the various shells, run the `bin/version_info.sh`
command. ::

  $ bin/shell_versions.sh
  os:Mac OS X version:10.5.3
  shell:/bin/bash version:3.2.17(1)-release
  shell:/bin/dash version:not_installed
  shell:/bin/ksh version:M-1993-12-28
  shell:/bin/pdksh version:not_installed
  shell:/bin/zsh version:4.3.4

Update Version
--------------

Edit ``src/shflags`` and change the version number in the ``FLAGS_VERSION``
variable.

Finish Documentation
--------------------

Make sure that any remaning changes get put into the ``CHANGES-X.X.txt`` file.

Finish writing the ``RELEASE_NOTES-X.X.X.txt``. Once it is finished, run it
through the **fmt** command to make it pretty. (This assumes the lines weren't
already wrapped at 80 chars when the file was edited.) ::

  $ fmt -w 80 RELEASE_NOTES-2.0.0.txt >RELEASE_NOTES-2.0.0.txt.new
  $ mv RELEASE_NOTES-2.0.0.txt.new RELEASE_NOTES-2.0.0.txt

We want to have an up-to-date version of the documentation in the release, so
we'd better build it. ::

  $ pwd
  .../shflags/source/1.0
  $ rst2html --stylesheet-path=doc/rst2html.css README.txt >README.html

Check In All the Code
---------------------

This step is pretty self-explainatory ::

  $ pwd
  .../shflags/source/1.0
  $ svn ci -m "finalizing 1.0.0 release"

Tag the Release
---------------
::

  $ cd ..
  $ pwd
  .../shflags/source
  $ ls
  1.0
  $ svn cp -m "Release 1.0.0" 1.0 https://shflags.googlecode.com/svn/tags/1.0.0

Export the Release
------------------
::

  $ cd ../builds
  $ pwd
  .../shflags/builds
  $ svn export https://shflags.googlecode.com/svn/tags/1.0.0 shflags-1.0.0

Create Tarball
--------------
::

  $ tar cfz ../releases/shflags-1.0.0.tgz shflags-1.0.0

md5sum the Tarball and Sign With gpg
------------------------------------
::

  $ cd ../releases
  $ md5sum shflags-1.0.0.tgz >shflags-1.0.0.tgz.md5
  $ gpg --default-key kate.ward@forestent.com --detach-sign shflags-1.0.0.tgz

Post the release
----------------

To post the release, the ProjectInfo page needs to be updated with the release
info (release, date, and MD5), and the release with GPG signature needs to
uploaded.

Post to Freshmeat
-----------------

- http://freshmeat.net/


Appendix
========

Related Documentation
---------------------

:google-gflags: http://code.google.com/p/google-gflags/

Miscellaneous
-------------

This document is written using the Restructured Text format to make it easily
parsable into an HTML file.


.. generate HTML using rst2html from Docutils of
.. http://docutils.sourceforge.net/
..
.. vim:syntax=rst:textwidth=80
.. $Revision$
