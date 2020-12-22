## How to uninstall a .deb package?

Ref: `https://unix.stackexchange.com/questions/195794/how-to-uninstall-a-deb-installed-with-dpkg`

### Question

I installed Unified Remote using dpkg:

```bash
dpkg -i urserver.deb
```

How do I uninstall it so I can reinstall from scratch?


### Answer

First of all you should check if this package is correctly installed in your system and being listed by dpkg tool:

```bash
dpkg -l | grep urserver
```

It should have an option `ii` in the first column of the output - that means _installed ok installed_.

If you'd like to remove the package itself (without the configuration files), you'll have to run:

```bash
dpkg -r urserver
```

If you'd like to delete (purge) the package completely (with configuration files), you'll have to run:

```bash
dpkg -P urserver
```

You may check if the package has been removed successfully - simply run again:

```bash
dpkg -l | grep urserver
```

If the package has been removed without configuration files, you'll see the `rc` status near the package name, otherwise, if you have purged the package completely, the output will be empty.