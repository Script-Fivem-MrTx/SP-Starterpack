ALTER TABLE `users`
ADD COLUMN `starterpack_umum_received` TINYINT(1) NOT NULL DEFAULT 0 ,
ADD COLUMN `starterpack_ladies_received` TINYINT(1) NOT NULL DEFAULT 0 AFTER `starterpack_umum_received`;
