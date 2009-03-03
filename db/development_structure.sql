CREATE TABLE `applications` (
  `id` int(11) NOT NULL auto_increment,
  `manufacturer` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_applications_on_manufacturer` (`manufacturer`,`version`,`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `client_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status` varchar(255) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_client_statuses_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `clients` (
  `id` int(11) NOT NULL auto_increment,
  `quick_clone_name` varchar(255) NOT NULL,
  `snapshot_name` varchar(255) NOT NULL,
  `suspended_at` datetime default NULL,
  `host_id` int(11) NOT NULL,
  `client_status_id` int(11) NOT NULL,
  `os_id` int(11) default NULL,
  `application_id` int(11) default NULL,
  `url_count` int(11) NOT NULL default '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_clients_on_quick_clone_name` (`quick_clone_name`,`snapshot_name`),
  KEY `index_clients_on_host_id` (`host_id`),
  KEY `index_clients_on_client_status_id` (`client_status_id`),
  KEY `index_clients_on_os_id` (`os_id`),
  KEY `index_clients_on_application_id` (`application_id`),
  KEY `index_clients_on_created_at` (`created_at`),
  KEY `index_clients_on_updated_at` (`updated_at`),
  KEY `index_clients_on_suspended_at` (`suspended_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `configurations` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `namespace` varchar(255) NOT NULL,
  `description` text,
  `default_value` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_configurations_on_value` (`value`,`name`,`namespace`),
  KEY `index_configurations_on_name` (`name`),
  KEY `index_configurations_on_namespace` (`namespace`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `file_contents` (
  `id` int(11) NOT NULL auto_increment,
  `md5` varchar(255) NOT NULL,
  `sha1` varchar(255) NOT NULL,
  `size` int(11) NOT NULL default '0',
  `mime_type` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_file_contents_on_size` (`size`,`sha1`,`md5`),
  KEY `index_file_contents_on_md5` (`md5`),
  KEY `index_file_contents_on_sha1` (`sha1`),
  KEY `index_file_contents_on_mime_type` (`mime_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fingerprints` (
  `id` int(11) NOT NULL auto_increment,
  `os_process_count` int(11) NOT NULL default '0',
  `checksum` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_fingerprints_on_checksum` (`checksum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hosts` (
  `id` int(11) NOT NULL auto_increment,
  `hostname` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_hosts_on_ip` (`ip`,`hostname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `job_alerts` (
  `id` int(11) NOT NULL auto_increment,
  `protocol` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `job_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_job_alerts_on_job_id` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `job_sources` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `protocol` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `by_unique_name_and_protocol` (`name`,`protocol`),
  KEY `index_job_sources_on_name` (`name`),
  KEY `index_job_sources_on_protocol` (`protocol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL auto_increment,
  `uuid` varchar(255) NOT NULL,
  `url_count` int(11) NOT NULL default '0',
  `completed_at` datetime default NULL,
  `job_source_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `by_unique_uuid` (`uuid`),
  KEY `index_jobs_on_uuid` (`uuid`),
  KEY `index_jobs_on_completed_at` (`completed_at`),
  KEY `index_jobs_on_created_at` (`created_at`),
  KEY `index_jobs_on_job_source_id` (`job_source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `os` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_os_on_name` (`name`,`version`,`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `os_processes` (
  `id` int(11) NOT NULL auto_increment,
  `name` text NOT NULL,
  `pid` int(11) NOT NULL,
  `parent_name` text,
  `parent_pid` int(11) default NULL,
  `process_file_count` int(11) NOT NULL default '0',
  `process_registry_count` int(11) NOT NULL default '0',
  `fingerprint_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_os_processes_on_fingerprint_id` (`fingerprint_id`),
  KEY `index_os_processes_on_namenamelength1024` (`name`(255)),
  KEY `index_os_processes_on_nameparent_namelength1024` (`parent_name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `process_files` (
  `id` int(11) NOT NULL auto_increment,
  `name` text NOT NULL,
  `event` varchar(255) NOT NULL,
  `time_at` decimal(30,6) NOT NULL,
  `file_content_id` int(11) default NULL,
  `os_process_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_process_files_on_file_content_id` (`file_content_id`),
  KEY `index_process_files_on_os_process_id` (`os_process_id`),
  KEY `index_process_files_on_namenamelength1024` (`name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `process_registries` (
  `id` int(11) NOT NULL auto_increment,
  `name` text NOT NULL,
  `event` varchar(255) NOT NULL,
  `value_name` text,
  `value_type` varchar(255) default NULL,
  `value` blob,
  `time_at` decimal(30,6) NOT NULL,
  `os_process_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_process_registries_on_os_process_id` (`os_process_id`),
  KEY `index_process_registries_on_namenamelength1024` (`name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `url_statistics` (
  `id` int(11) NOT NULL auto_increment,
  `count` int(11) NOT NULL default '0',
  `url_status_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `by_unique_range` (`created_at`,`updated_at`,`url_status_id`),
  KEY `index_url_statistics_on_created_at` (`created_at`),
  KEY `index_url_statistics_on_updated_at` (`updated_at`),
  KEY `index_url_statistics_on_url_status_id` (`url_status_id`),
  KEY `index_url_statistics_on_count` (`count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `url_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status` varchar(255) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `by_unique_status` (`status`),
  KEY `index_url_statuses_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

CREATE TABLE `urls` (
  `id` int(11) NOT NULL auto_increment,
  `time_at` decimal(30,6) default NULL,
  `url` text NOT NULL,
  `priority` int(11) NOT NULL default '1',
  `client_id` int(11) default NULL,
  `url_status_id` int(11) NOT NULL,
  `fingerprint_id` int(11) default NULL,
  `job_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_urls_on_time_at` (`time_at`),
  KEY `index_urls_on_created_at` (`created_at`),
  KEY `index_urls_on_client_id` (`client_id`),
  KEY `index_urls_on_fingerprint_id` (`fingerprint_id`),
  KEY `index_urls_on_url_status_id` (`url_status_id`),
  KEY `index_urls_on_job_id` (`job_id`),
  KEY `index_urls_on_priority` (`priority`),
  KEY `index_urls_on_nameurllength1024` (`url`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090227045745');

INSERT INTO schema_migrations (version) VALUES ('20090227050428');

INSERT INTO schema_migrations (version) VALUES ('20090227052517');

INSERT INTO schema_migrations (version) VALUES ('20090227052806');

INSERT INTO schema_migrations (version) VALUES ('20090227200843');

INSERT INTO schema_migrations (version) VALUES ('20090227201409');

INSERT INTO schema_migrations (version) VALUES ('20090227201533');

INSERT INTO schema_migrations (version) VALUES ('20090227233221');

INSERT INTO schema_migrations (version) VALUES ('20090227234029');

INSERT INTO schema_migrations (version) VALUES ('20090228003641');

INSERT INTO schema_migrations (version) VALUES ('20090228004356');

INSERT INTO schema_migrations (version) VALUES ('20090228011551');

INSERT INTO schema_migrations (version) VALUES ('20090228021931');

INSERT INTO schema_migrations (version) VALUES ('20090228024243');

INSERT INTO schema_migrations (version) VALUES ('20090228030713');

INSERT INTO schema_migrations (version) VALUES ('20090228031303');

INSERT INTO schema_migrations (version) VALUES ('20090228170041');