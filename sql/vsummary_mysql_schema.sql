/*
=============
vSummary
MYSQL SCHEMA
=============
*/

CREATE TABLE vm
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
moref VARCHAR(16),
vmx_path VARCHAR(255),
vcpu SMALLINT UNSIGNED,
memory_mb INT UNSIGNED,
config_guest_os VARCHAR(128),
config_version VARCHAR(16),
smbios_uuid VARCHAR(36),
instance_uuid VARCHAR(36),
config_change_version VARCHAR(64),
guest_tools_version VARCHAR(32),
guest_tools_running VARCHAR(32),
guest_hostname VARCHAR(128),
guest_ip VARCHAR(255),
stat_cpu_usage INT UNSIGNED,
stat_host_memory_usage INT UNSIGNED,
stat_guest_memory_usage INT UNSIGNED,
stat_uptime_sec INT UNSIGNED,
power_state TINYINT UNSIGNED,
esxi_id VARCHAR(32),
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE esxi
(
id VARCHAR(32) PRIMARY KEY,	
name VARCHAR(128),
moref VARCHAR(16),
max_evc VARCHAR(64),
current_evc VARCHAR(64),
status VARCHAR(32),
power_state TINYINT UNSIGNED,
in_maintenance_mode INT,
vendor VARCHAR(64),
model VARCHAR(64),
uuid VARCHAR(36),
memory_bytes BIGINT UNSIGNED,
cpu_model VARCHAR(64),
cpu_mhz INT UNSIGNED,
cpu_sockets SMALLINT UNSIGNED,
cpu_cores SMALLINT UNSIGNED,
cpu_threads SMALLINT UNSIGNED,
nics SMALLINT UNSIGNED,
hbas SMALLINT UNSIGNED,
version VARCHAR(32),
build VARCHAR(32),
stat_cpu_usage INT UNSIGNED,
stat_memory_usage BIGINT UNSIGNED,
stat_uptime_sec INT UNSIGNED,
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE datastore
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
moref VARCHAR(16),
status VARCHAR(32),
capacity_bytes BIGINT UNSIGNED,
free_bytes BIGINT UNSIGNED,
uncommitted_bytes BIGINT UNSIGNED,
type VARCHAR(32),
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE vdisk
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
capacity_bytes BIGINT UNSIGNED,
path VARCHAR(255),
thin_provisioned TINYINT UNSIGNED,
datastore_id VARCHAR(32),
uuid VARCHAR(32),
disk_object_id VARCHAR(32),
vm_id VARCHAR(32),
esxi_id VARCHAR(32),
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE vcenter
(
id VARCHAR(36) PRIMARY KEY,
name VARCHAR(128),
present TINYINT DEFAULT 1
);


CREATE TABLE pnic
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
mac VARCHAR(17),
link_speed SMALLINT UNSIGNED,
driver VARCHAR(45),
esxi_id VARCHAR(32),
vswitch_id VARCHAR(32) DEFAULT null,
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE vswitch
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
type VARCHAR(64),
version VARCHAR(32) DEFAULT null,
max_mtu SMALLINT UNSIGNED DEFAULT 0,
ports SMALLINT UNSIGNED DEFAULT 0,
esxi_id VARCHAR(32) DEFAULT null,
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE portgroup
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
type VARCHAR(32),
vlan VARCHAR(128),
vlan_type VARCHAR(64),
vswitch_id VARCHAR(32),
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);

CREATE TABLE vnic
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(64),
mac VARCHAR(17),
type VARCHAR(45),
connected VARCHAR(16),
status VARCHAR(16),
vm_id VARCHAR(32),
portgroup_id VARCHAR(32),
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);






CREATE TABLE vmknic
(
id VARCHAR(32) PRIMARY KEY,
name VARCHAR(128),
mac VARCHAR(17),
mtu SMALLINT UNSIGNED,
ip VARCHAR(45),
netmask VARCHAR(32),
portgroup_id VARCHAR(32),
esxi_id VARCHAR(32),
vcenter_id VARCHAR(36),
present TINYINT DEFAULT 1
);



















SELECT  vm.name, esxi.name, coalesce(COUNT(vdisk.id),0) AS vdisks
FROM    vm
LEFT OUTER JOIN
        vdisk
ON      vm.id = vdisk.vm_id
LEFT JOIN
        esxi
ON      vm.esxi_id = esxi.id
WHERE   vm.present = 1 AND vdisk.present = 1 AND esxi.present = 1
GROUP BY
        vm.id;



CREATE VIEW view_vm AS
SELECT  vm.name, esxi.name AS esxi_name, coalesce(COUNT(vdisk.id),0) AS vdisks
FROM    vm
LEFT JOIN
        vdisk
ON      vm.id = vdisk.vm_id
    AND vm.present = 1
    AND vdisk.present = 1
LEFT JOIN
        esxi
ON      vm.esxi_id = esxi.id
GROUP BY
        vm.id;


CREATE VIEW view_vnic AS
SELECT  vnic.name, vnic.mac, vnic.connected, vnic.status, vnic.vcenter_id,
  vm.name AS vm_name, 
  esxi.name AS esxi_name, 
  coalesce(portgroup.name,"ORPHANED") AS portgroup_name,
  portgroup.vlan,
  coalesce(vswitch.name,"ORPHANED") AS vswitch_name, 
  vswitch.type AS vswitch_type,
  vswitch.max_mtu
FROM    vnic
LEFT JOIN
        portgroup
ON      vnic.portgroup_id = portgroup.id
    AND vnic.present = 1
    AND portgroup.present = 1
LEFT JOIN
        vm
ON      vnic.vm_id = vm.id
LEFT JOIN
        esxi
ON      vm.esxi_id = esxi.id
LEFT JOIN
        vswitch
ON      portgroup.vswitch_id = vswitch.id
GROUP BY
        vnic.id;