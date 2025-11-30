CREATE DATABASE IF NOT EXISTS `airdrop` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `airdrop`;

CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户主键ID',
    `wallet` VARCHAR(64) NOT NULL COMMENT '钱包地址，唯一',
    `login_streak` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '连续登录天数',
    `login_days` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '累计登录天数',
    `last_login_at` DATETIME NULL COMMENT '上次登录时间',
    `points_balance` BIGINT NOT NULL DEFAULT 0 COMMENT '当前可用积分',
    `frozen_points` BIGINT NOT NULL DEFAULT 0 COMMENT '冻结积分',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_wallet` (`wallet`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE IF NOT EXISTS `tasks` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务主键ID',
    `code` VARCHAR(64) NOT NULL COMMENT '任务唯一标识',
    `name` VARCHAR(128) NOT NULL COMMENT '任务名称',
    `description` TEXT NULL COMMENT '任务描述',
    `base_points` INT NOT NULL DEFAULT 0 COMMENT '基础积分',
    `max_points` INT NULL COMMENT '可获得最大积分',
    `stackable` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否可叠加',
    `metadata` JSON NULL COMMENT '任务元数据',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务表';

CREATE TABLE IF NOT EXISTS `user_tasks` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户任务记录ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '关联用户ID',
    `task_code` VARCHAR(64) NOT NULL COMMENT '任务Code',
    `amount` BIGINT NOT NULL DEFAULT 0 COMMENT '完成数量或次数',
    `points` BIGINT NOT NULL DEFAULT 0 COMMENT '获得积分',
    `unique_key` VARCHAR(128) NOT NULL DEFAULT '' COMMENT '去重键',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_task_once` (`user_id`, `task_code`, `unique_key`),
    KEY `idx_user_task` (`user_id`, `task_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户任务记录表';

CREATE TABLE IF NOT EXISTS `points_ledger` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '积分流水ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '关联用户ID',
    `delta` BIGINT NOT NULL COMMENT '积分变动值',
    `reason` VARCHAR(64) NOT NULL COMMENT '变动原因',
    `ref_id` BIGINT UNSIGNED NULL COMMENT '关联业务ID',
    `meta` JSON NULL COMMENT '额外元数据',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_created` (`user_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分流水表';

CREATE TABLE IF NOT EXISTS `airdrop_rounds` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '空投轮次ID',
    `name` VARCHAR(64) NOT NULL COMMENT '轮次名称',
    `merkle_root` VARCHAR(128) NOT NULL COMMENT 'MerkleRoot',
    `token_address` VARCHAR(64) NOT NULL COMMENT '代币合约地址',
    `claim_deadline` DATETIME NOT NULL COMMENT '领取截止时间',
    `status` VARCHAR(32) NOT NULL DEFAULT 'draft' COMMENT '轮次状态',
    `snapshot_at` DATETIME NULL COMMENT '快照时间',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='空投轮次表';

CREATE TABLE IF NOT EXISTS `round_points` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '轮次积分记录ID',
    `round_id` BIGINT UNSIGNED NOT NULL COMMENT '关联轮次ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '关联用户ID',
    `points` BIGINT NOT NULL COMMENT '分配积分',
    `claimed_points` BIGINT NOT NULL DEFAULT 0 COMMENT '已领取积分',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_round_user` (`round_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='轮次积分表';

CREATE TABLE IF NOT EXISTS `claims` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '领取记录ID',
    `round_id` BIGINT UNSIGNED NOT NULL COMMENT '关联轮次ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '关联用户ID',
    `wallet` VARCHAR(64) NOT NULL COMMENT '钱包地址',
    `amount` BIGINT NOT NULL COMMENT '领取积分数量',
    `tx_hash` VARCHAR(128) NULL COMMENT '交易哈希',
    `status` VARCHAR(32) NOT NULL DEFAULT 'pending' COMMENT '领取状态',
    `claimed_at` DATETIME NULL COMMENT '领取时间',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_round_wallet` (`round_id`, `wallet`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='领取记录表';
