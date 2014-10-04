Neo4j Server Ansible Role
========

This is an Ansible role to configure a Neo4j server on Ubuntu.
It comes with Vagrant configuration to test the role.

* Neo4j: [http://www.neo4j.org/](http://www.neo4j.org/)
* Ansible: [http://www.ansible.com/home](http://www.ansible.com/home)
* Vagrant: [http://www.vagrantup.com](http://www.vagrantup.com)


Requirements
------------

This role was tested on Ubuntu Precise (12).

Optional: Install Vagrant if you plan to use it.

Role Variables
--------------

Below are all the variables from default/main.yml.
Except for the first 2 that specify which package to install, all of them are copied to the neo4j-server.properties

		# Specify which Neo4j version you want to install
		neo4j_package: neo4j-enterprise
		neo4j_package_version: 2.0.0

		# Server configuration
		neo4j_server_database_location: data/graph.db
		neo4j_server_webserver_address: 0.0.0.0
		neo4j_server_webserver_port: 7474
		neo4j_server_webserver_https_enabled: true
		neo4j_server_webserver_https_port: 7473
		neo4j_server_webserver_https_cert_location: conf/ssl/snakeoil.cert
		neo4j_server_webserver_https_key_location: conf/ssl/snakeoil.key
		neo4j_server_webserver_https_keystore_location: data/keystore

		# Administration client configuration
		neo4j_server_webadmin_rrdb_location: data/rrd
		neo4j_server_webadmin_data_uri: /db/data/
		neo4j_server_webadmin_management_uri: /db/manage/
		neo4j_server_db_tuning_properties: conf/neo4j.properties
		neo4j_server_manage_console_engines: shell
		neo4j_server_database_mode: SINGLE

		# HTTP logging configuration
		neo4j_server_http_log_enabled: false
		neo4j_server_http_log_config: conf/neo4j-http-logging.xml

Dependencies
------------

* [briancoca.oracle_java7](https://galaxy.ansible.com/list#/roles/628) to use Oracle Java 7

Example Playbook
-------------------------

To use this role in your playbook, the simplest is (using default configuration):

    - hosts: neo4j_servers
      roles:
         - julienroubieu.neo4j

If you want to override some variable:

    - hosts: neo4j_servers
      roles:
         - { role: julienroubieu.neo4j, neo4j_server_webserver_port: 8080 }


Vagrant
------------

This project is also integrated with Vagrant. You can use Vagrant to create a local VM and test this role.

To do this:

* Install Vagrant from [http://www.vagrantup.com](http://www.vagrantup.com/downloads.html)
* Run `vagrant up` to turn the VM on and automatically run the vagrant.yml playbook.
* To run it again, 2 solutions:
  * From vagrant: `vagrant provision`
  * From ansible directly: `ansible-playbook -s -i vagrant_host vagrant.yml -vv`
* Open http://localhost:7474 from your browser to access Neo4j web console.

If a port conflict is detected (for example if you already have Neo4j running locally on 7474), edit vars/vagrant.yml and Vagrantfile.

The VM will reboot after the first install.

License
-------

BSD

Author Information
------------------

Julien Roubieu - jroubieu gmail com
