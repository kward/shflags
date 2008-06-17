====================
shFlags 1.0.x README
====================

code.google.com
===============

This project is stored on code.google.com as http://code.google.com/p/shflags/.
The source code is stored in Subversion and can be accessed using the following
information.

Check out the code locally ::

  $ svn checkout http://shflags.googlecode.com/svn/trunk/ shflags-read-only

Browse the code in a web browser:

- http://code.google.com/p/shflags/source/browse
- svn > trunk > source > 1.0


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

To get the versions of the various shells, run the bin/version_info.sh command.
::

  $ bin/version_info.sh
  os:Mac OS X version:10.5.3
  shell:/bin/bash version:3.2.17(1)-release
  shell:/bin/dash version:not_installed
  shell:/bin/ksh version:M-1993-12-28
  shell:/bin/pdksh version:not_installed
  shell:/bin/zsh version:4.3.4

Update Version
--------------

Edit ``src/shflags`` and change the version number in the ``__FLAGS_VERSION``
variable. Next, edit the ``src/docbook/shflags.xml`` file, edit the version in
the ``<title>`` element, and make sure there is a revision section for this
release.

Finish Documentation
--------------------

Make sure that any remaning changes get put into the ``CHANGES-X.X.txt`` file.

Finish writing the ``RELEASE_NOTES-X.X.X.txt``. Once it is finished, run it
through the **fmt** command to make it pretty. ::

  $ fmt -w 80 RELEASE_NOTES-2.0.0.txt >RELEASE_NOTES-2.0.0.txt.new
  $ mv RELEASE_NOTES-2.0.0.txt.new RELEASE_NOTES-2.0.0.txt

We want to have an up-to-date version of the documentation in the release, so
we'd better build it. ::

  $ pwd
  .../shflags/source/1.0
  $ make docs
  ...
  $ cp -p build/shunit2.html doc
  $ rst2html --stylesheet-path=share/css/rst2html.css doc/README.txt >doc/README.html

Check In All the Code
---------------------

This step is pretty self-explainatory ::

  $ pwd
  .../shunit2/source/2.0
  $ svn ci -m "finalizing release"

Tag the Release
---------------
::

  $ pwd
  .../shunit2/source
  $ ls
  2.0  2.1
  $ svn cp -m "Release 2.0.0" 2.0 https://shunit2.svn.sourceforge.net/svnroot/shunit2/tags/source/2.0.0

Export the Release
------------------
::

  $ pwd
  .../shunit2/builds
  $ svn export https://shunit2.svn.sourceforge.net/svnroot/shunit2/tags/source/2.0.0 shunit2-2.0.0

Create Tarball
--------------
::

  $ tar cfz ../releases/shunit2-2.0.0.tgz shunit2-2.0.0

md5sum the Tarball and Sign With gpg
------------------------------------
::

  $ cd ../releases
  $ md5sum shunit2-2.0.0.tgz >shunit2-2.0.0.tgz.md5
  $ gpg --default-key kate.ward@forestent.com --detach-sign shunit2-2.0.0.tgz

Update Website
--------------

Again, pretty self-explainatory. Make sure to copy the MD5 and GPG signature
files. Once that is done, make sure to tag the website so we can go back in
time if needed. ::

  $ pwd
  .../shunit2
  $ ls
  source  website
  $ svn cp -m "Release 2.0.0" \
  website https://shunit2.svn.sourceforge.net/svnroot/shunit2/tags/website/20060916

Now, update the website. It too is held in Subversion, so **ssh** into
SourceForge and use ``svn up`` to grab the latest version.

Post to SourceForge and Freshmeat
---------------------------------

- http://sourceforge.net/projects/shunit2/
- http://freshmeat.net/


Related Documentation
=====================

:Docbook: http://www.docbook.org/
:Docbook XML:
  :docbook-xml-4.4.zip:
    http://www.docbook.org/xml/4.4/docbook-xml-4.4.zip
    http://www.oasis-open.org/docbook/xml/4.4/docbook-xml-4.4.zip
  :docbook-xml-4.5.zip:
    http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip
:Docbook XSL:
  :docbook-xsl-1.71.0.tar.bz2:
    http://prdownloads.sourceforge.net/docbook/docbook-xsl-1.71.0.tar.bz2?download
  :docbook-xsl-1.71.1.tar.bz2:
    http://downloads.sourceforge.net/docbook/docbook-xsl-1.71.1.tar.bz2?use_mirror=puzzle
:JUnit: http://www.junit.org/

..
.. generate HTML using rst2html from Docutils of
.. http://docutils.sourceforge.net/
..
.. vim:syntax=rst:textwidth=80
.. $Revision$
