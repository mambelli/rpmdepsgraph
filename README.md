<!-- SPDX-FileCopyrightText: 2025 Marco Mambelli -->
<!-- SPDX-License-Identifier: Apache-2.0 -->


# RPMDepsGraph

Simple bash script to create a graph of RPM packages' dependencies.
The output is in dot (<https://graphviz.org/doc/info/lang.html>) 
directed graph format, and can be displayed or printed using the
dotty graph editor from the graphviz package.

Requires the `rpm` command.
Just download and use it. Add it to your path if desired.

To learn more about what it does and how to use it type `./rpmdepsgraph.sh -h`:
```
rpmdepsgraph.sh [options] RPM_FILES
Create a graph of RPM dependencies in a set of RPM packages.
The output is in dot(https://graphviz.org/doc/info/lang.html) 
directed graph format, and can be displayed or printed using the
dotty graph editor from the graphviz package.  
  -h       print this message
  -v       verbose mode
  -k KEY   if 1 or more "-k" option is present, add all KEYs to a KEEP_LIST
           and keep only dependencies starting with one of the KEYs
  -x KEY   if 1 or more "-x" option is present, add all KEYs to a REJECT_LIST
           and reject all dependencies starting with one of the KEYs
  -t STR   graph title. Defaults to "RPM Dependencies"
  -o PATH  output file path (name and directory). Defaults to stdout
Examples:
 rpmdepsgraph.sh -t MyPackage dist/mypackage*rpm > mypackage.dot
 dot -Tsvg mypackage.dot > mypackage.svg
Similar commands:
 rpmgraph (from rpm-devel RPM) is working as well on package files
but is not listing all dependencies, and has no filtering.
 rpmgraph.py (https://codeberg.org/htgoebel/rpmgraph) is using the
RPM db and is Python 2 code.
 dnf repograph
 dnf repoquery  --tree --requires mypackage-sub_a-3.10.10 --qf "%{name}"
both use the RPM db and print/graph too many dependencies 
```

Distributed under the [Apache License v2.0](LICENSE).
