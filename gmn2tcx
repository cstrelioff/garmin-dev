#!/bin/bash

# Copyright (c) 2009 Braiden Kindt
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

set -o pipefail

# validate the given xml against garmin's
# published xsd. return 0 if our input file
# matches. If our file does not match,
# highly unlikely that uploading will succeed.
# this method always returns true if 'xmllint'
# program in unavailible.
function validate_xml {
  XMLLINT=`which xmllint`
  if [ ! -z "$XMLLINT" ] ; then
    $XMLLINT --schema `dirname $0`/tcx.xsd -
  else
    echo "WARN: \"xmllint\" not found. Will not validate XML schema." 1>&2
    cat
  fi
}

# user garmin_dump (part of garmin tools)
# to dump an xml represntation of the run.
# this is a raw xml represntation, not the
# converted tcx.
function do_dump {
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
  echo "<garmin_dumps>"
  for file in "$@" ; do 
    if [ -r "$file" ] ; then
      echo "<garmin_dump>"
      garmin_dump "$file"
      echo "</garmin_dump>"
    else
      echo "WARNING: $file not readable." >&2
    fi
  done
  echo "</garmin_dumps>"
}
 
# invoke xslt processor creating a TCX containg data from all provided .mgn files
`dirname $0`/saxon-xslt <(do_dump "$@") `dirname $0`/gmn2tcx.xslt | validate_xml
