# How do I disable my system from going to sleep?

On Ubuntu 16.04 LTS, I successfully used the following to disable suspend:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

And this to re-enable it:

```bash
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

From `man systemctl`:

```
mask NAME...  
           Mask one or more units, as specified on the command line. This
           will link these unit files to /dev/null, making it impossible to
           start them. This is a stronger version of disable, since it
           prohibits all kinds of activation of the unit, including
           enablement and manual activation. Use this option with care. This
           honors the --runtime option to only mask temporarily until the
           next reboot of the system. The --now option may be used to ensure
           that the units are also stopped. This command expects valid unit
           names only, it does not accept unit file paths.

unmask NAME...
           Unmask one or more unit files, as specified on the command line.
           This will undo the effect of mask. This command expects valid
           unit names only, it does not accept unit file paths.
```