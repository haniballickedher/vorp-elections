-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.3.38-MariaDB-0ubuntu0.20.04.1 - Ubuntu 20.04
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table vorpv2.ballot
DROP TABLE IF EXISTS `ballot`;
CREATE TABLE IF NOT EXISTS `ballot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `candidate_name` varchar(255) NOT NULL,
  `position` varchar(255) NOT NULL,
  `region` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table vorpv2.ballot: ~21 rows (approximately)
DELETE FROM `ballot`;

-- Dumping structure for table vorpv2.ballot_registration
DROP TABLE IF EXISTS `ballot_registration`;
CREATE TABLE IF NOT EXISTS `ballot_registration` (
  `registrationID` int(11) NOT NULL AUTO_INCREMENT,
  `voterID` int(11) NOT NULL,
  `registrationCity` varchar(50) NOT NULL,
  `registrationRegion` varchar(50) NOT NULL,
  PRIMARY KEY (`registrationID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table vorpv2.ballot_registration: ~3 rows (approximately)
DELETE FROM `ballot_registration`;

-- Dumping structure for table vorpv2.ballot_votes
DROP TABLE IF EXISTS `ballot_votes`;
CREATE TABLE IF NOT EXISTS `ballot_votes` (
  `voteID` int(11) NOT NULL AUTO_INCREMENT,
  `voterID` int(11) NOT NULL,
  `ballotID` int(11) NOT NULL,
  `datetimestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `office` varchar(50) DEFAULT NULL,
  `jurisdiction` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`voteID`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='contains the votes for candidates (in the ballot table)';

-- Dumping data for table vorpv2.ballot_votes: ~1 rows (approximately)
DELETE FROM `ballot_votes`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
