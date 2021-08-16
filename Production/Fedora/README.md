Fedora package for InfiniteShooter
==================================
Instructions taken from https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/. Basically, ensure that:  
- you are using Fedora
- you are in the "mock" group: `# usermod -a -G mock yourusername`
- you have these packages installed: `# dnf install fedora-packager fedora-review`  
And then CD to this directory and type `fedpkg --release f34 local`. The RPM will be under `x86_64`.
