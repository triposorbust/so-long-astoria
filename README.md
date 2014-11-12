So Long, Astoria!
===

Go ahead, simulate away!
---

A small **particle simulation** system. Barnes-Hut simulation that traces particles over time.

### Quickstart

Provided are `Vagrantfile` and `provision.sh` scripts for booting up in a virtualized environment.

```
% vagrant up
% vagrant ssh
vagrant@precise32:/~$ cd /vagrant
vagrant@precise32:/vagrant$ make
vagrant@precise32:/vagrant$ ./solong
```

Should begin running a small simulation!

![Screenshot](/screenshot.png)

### Contents

Source available in `/src`, contains the following:

 - `BHTree`: Barnes-Hut spatial indexing tree.
 - `Displayer`: Objective-C Xlib client for rendering things.
 - `Simulation`: Runs the simulation by computing successive forces.
 - `Simulation+Render`: Logic for displaying `Simulation` on `Displayer`.


### Parameters

Are sort of scattered all over the place right now, usually in the header files. `G` (gravitational constant) is defined in `BHTree.h`. Initial velocities and maximum speeds are defined in `Simulation.h`. Display-related parameters in `Displayer` and `Simulation+Render`.

Sorry, not in a clean bundle. Yet.


### Dependencies

Should have an X11 server on the host machine. Client [if not in VM] should have a C compiler and Objective-C runtime as well as a copy of Xlib.


### Authors

 - Andy C. (Columbia University)
 - ...


### License

Released under the MIT License.

Copyright &copy; 2014 Andy Chiang.