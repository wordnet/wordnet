# Simple sudoers role

This role installs sudo package, ensure that /etc/sudoers.d included and
create or remove sudoers files in /etc/sudoers.d.
For now, each sudoer has access to all commands within a variable set of users, and global setting determines whether
NOPASSWD is set or not.

## Variables

 * sudoers_filename - file name in /etc/sudoers.d (required)
 * sudoers - A dictonary of users who have sudo access and to what users they have 
   permission to execute commands as. Use '%foo' to specify that users in a given
   group have sudo access.
   * defaults: []
   * example: Check ```ansible-sudoers.yml``` playbook for an example where user 
   ```testone``` as permission to execute commands as users ```vagrant``` and
   ```root```and user ```testtwo``` has permission to execute commands as any user.
 * sudoers_nopasswd - if set, NOPASSWD is added to all sudoers entries. Use this
   when users don't have passwords set.
   * default: true
 * sudoers_remove - if enabled, remove /etc/sudoers.d/{{ sudoers\_filename }} instead
   of create.
   * default: false

## TODO
 * Ability to create users with not full access
