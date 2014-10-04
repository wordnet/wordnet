## ANXS - MySQL [![Build Status](https://travis-ci.org/ANXS/mysql.png)](https://travis-ci.org/ANXS/mysql)

Ansible role that installs MySQL on (for now) Ubuntu variants.
Features include:
- Installation of MySQL and it's dependencies
- Basic configuration
- Standard hardening (root password, removal of test databases)
- Add databases
- Add users
- Setup of monit process supervision


#### Requirements & Dependencies
- Tested on Ansible 1.4 or higher.
- ANXS.monit if you want monit protection (in that case, you should set `monit_protection: true`)


#### Variables

```yaml
# Basic settings
mysql_port: 3306                        # The port on which mysql listens
mysql_bind_address: "0.0.0.0"           # The address the mysql server binds on
mysql_root_password: 'pass'             # The root password

# Fine Tuning
mysql_key_buffer: '16M'
mysql_max_allowed_packet: '128M'
mysql_thread_stack: '192K'
mysql_cache_size: 8
mysql_myisam_recover: 'BACKUP'
mysql_max_connections: 100
mysql_table_cache: 64
mysql_thread_concurrency: 10
mysql_query_cache_limit: '1M'
mysql_query_cache_size: '16M'
mysql_character_set_server: 'utf8'
mysql_collation_server: 'utf8_general_ci'
mysql_mysqldump_max_allowed_packet: '128M'
mysql_isamchk_key_buffer: '16M'

# InnoDB tuning
mysql_innodb_file_per_table: 'innodb_file_per_table'
mysql_innodb_flush_method: 'fdatasync'
mysql_innodb_buffer_pool_size: '128M'
mysql_innodb_flush_log_at_trx_commit: 1
mysql_innodb_lock_wait_timeout: 50
mysql_innodb_log_buffer_size: '1M'
mysql_innodb_log_file_size: '5M'

# List of databases to be created (optional)
mysql_databases:
  - name: foobar
    collation: "utf8_general_ci"        # optional, defaults to "utf8_general_ci"
    encoding: "utf8"                    # optional, defaults to "utf8"

# List of users to be created (optional)
mysql_users:
  - name: baz
    pass: pass
    priv: "*.*:ALL"                     # optional, defaults to "*.*:ALL"
    host: "%"                           # optional, defaults to "localhost"

# GLOBAL Setting
monit_protection: false                 # true or false, requires ANXS.monit
```


#### License

Licensed under the MIT License. See the LICENSE file for details.


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/mysql/issues)!
