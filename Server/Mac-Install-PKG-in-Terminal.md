

    /usr/sbin/installer

> The installer command is used to install Mac OS X installer packages to a specified domain or volume. The installer command installs a single package per invocation, which is specified with the -package parameter ( -pkg is accepted as a synonym). It may be either a single package or a metapackage. In the case of the metapackage, the packages which are part of the default install will be installed unless disqualified by a package's check tool(s).

See man installer for the full functionality. Often

    sudo installer -pkg /path/to/package.pkg -target /

is all that's needed.

Ref: https://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal
