oracle_java
========

This role installs the official Oracle java

Requirements
------------

This role requires the debconf module for Debian derived distros (included in the role and might be removed once accepted in ansible)

Role Variables
--------------

A few vars you can override now, it should even be possible to install java8.

    oracle_packages:
        - oracle-java7-installer
        - oracle-java7-set-default

    oracle_installer_key: oracle-java7-installer
    oracle_license_key: accepted-oracle-license-v1-1


Dependencies
------------

Only that you have tried using OpenJDK first.
Also you need python module pycurl installed.

License
-------

GPLv2

Author Information
------------------

briancoca+orajava@gmail.com
