autowake_NAS
============

DESCRIPTION
===========

More and more small offices and home power users store their data in a central NAS, that can be accessed from any computer of the network.
Most of the NAS users do not need to access their NAS all the time (e.g. during the week-end for small offices, or during working time for home users)

In order to save energy and increase the life time of the components, it is beneficial to switch OFF the NAS when it is not required.
But it is cumbersome to allways switch ON/OFF the NAS. So any non automatic solution if not practical...

Therefore I developped this script (running on my linux based DD-WRT Router) to automatically wake on LAN my NAS according to various conditions:
 - If at least one of a configurable set of devices is online
 - Unless a curfew timeslot is defined and the current time is within this slot
 - Every day at configurable time

You may wonder how to automatically shutdown / suspend to RAM your NAS. If you have a FreeBSD based NAS (e.g. NAS4Free or FreeNAS), you may be interrested by the following scripts:
https://github.com/fritz-hh/scripts_NAS4Free

PREREQUISITE
============

- A DD-WRT router
- A NAS supporting Wake on LAN (WoL) from magic paket

INSTALL
=======

- Copy the content of the https://github.com/fritz-hh/autowake_NAS/blob/master/wake_NAS.sh file into the Commands textfield in the DD-WRT section Adminstration|Commands (see below).
- Press the "Save Startup" button.
- Restart your router

![Startup Commands](https://github.com/fritz-hh/autowake_NAS/raw/master/screenshots/dd-wrt_commands.PNG)

DISCLAIMER
==========

Of course, the scripts are provided without any warranty!
(I am nor a unix/linux expert nor a SW developper, but a simple user)

Any contribution (new functions, fixes, problem reports) is welcome!

Feel free to use the scripts on your own router!

Kind Regards,

fritz
