CREATE DATABASE IF NOT EXISTS swo_assignment;

USE swo_assignment;

CREATE TABLE IF NOT EXISTS  `smashes` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

