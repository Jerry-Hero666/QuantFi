package entity

import (
	"time"

	"gorm.io/datatypes"
)

type User struct {
	ID            uint64     `gorm:"primaryKey;autoIncrement;comment:'用户主键ID'"`
	Wallet        string     `gorm:"size:64;uniqueIndex;comment:'钱包地址，唯一'"`
	LoginStreak   uint32     `gorm:"column:login_streak;comment:'连续登录天数'"`
	LoginDays     uint64     `gorm:"column:login_days;comment:'累计登录天数'"`
	LastLoginAt   *time.Time `gorm:"column:last_login_at;comment:'上次登录时间'"`
	PointsBalance int64      `gorm:"column:points_balance;comment:'当前可用积分'"`
	FrozenPoints  int64      `gorm:"column:frozen_points;comment:'冻结积分'"`
	CreatedAt     time.Time  `gorm:"column:created_at;autoCreateTime;comment:'创建时间'"`
	UpdatedAt     time.Time  `gorm:"column:updated_at;autoUpdateTime;comment:'更新时间'"`
}

func (User) TableName() string {
	return "users"
}

type Task struct {
	ID          uint64         `gorm:"primaryKey;comment:'任务主键ID'"`
	Code        string         `gorm:"size:64;uniqueIndex;comment:'任务唯一标识'"`
	Name        string         `gorm:"size:128;comment:'任务名称'"`
	Description string         `gorm:"type:text;comment:'任务描述'"`
	BasePoints  int64          `gorm:"column:base_points;comment:'基础积分'"`
	MaxPoints   *int64         `gorm:"column:max_points;comment:'可获得最大积分'"`
	Stackable   bool           `gorm:"column:stackable;comment:'是否可叠加'"`
	Metadata    datatypes.JSON `gorm:"column:metadata;comment:'任务元数据'"`
	CreatedAt   time.Time      `gorm:"column:created_at;comment:'创建时间'"`
	UpdatedAt   time.Time      `gorm:"column:updated_at;comment:'更新时间'"`
}

func (Task) TableName() string {
	return "tasks"
}

type UserTask struct {
	ID        uint64    `gorm:"primaryKey;comment:'用户任务记录ID'"`
	UserID    uint64    `gorm:"column:user_id;index;comment:'关联用户ID'"`
	TaskCode  string    `gorm:"column:task_code;size:64;comment:'任务Code'"`
	Amount    int64     `gorm:"column:amount;comment:'完成数量或次数'"`
	Points    int64     `gorm:"column:points;comment:'获得积分'"`
	UniqueKey string    `gorm:"column:unique_key;size:128;comment:'去重键'"`
	CreatedAt time.Time `gorm:"column:created_at;comment:'创建时间'"`
}

func (UserTask) TableName() string {
	return "user_tasks"
}

type PointsLedger struct {
	ID        uint64         `gorm:"primaryKey;comment:'积分流水ID'"`
	UserID    uint64         `gorm:"column:user_id;index;comment:'关联用户ID'"`
	Delta     int64          `gorm:"column:delta;comment:'积分变动值'"`
	Reason    string         `gorm:"column:reason;size:64;comment:'变动原因'"`
	RefID     *uint64        `gorm:"column:ref_id;comment:'关联业务ID'"`
	Meta      datatypes.JSON `gorm:"column:meta;comment:'额外元数据'"`
	CreatedAt time.Time      `gorm:"column:created_at;comment:'创建时间'"`
}

func (PointsLedger) TableName() string {
	return "points_ledger"
}

type AirdropRound struct {
	ID            uint64     `gorm:"primaryKey;comment:'空投轮次ID'"`
	Name          string     `gorm:"size:64;comment:'轮次名称'"`
	MerkleRoot    string     `gorm:"column:merkle_root;size:128;comment:'MerkleRoot'"`
	TokenAddress  string     `gorm:"column:token_address;size:64;comment:'代币合约地址'"`
	ClaimDeadline time.Time  `gorm:"column:claim_deadline;comment:'领取截止时间'"`
	Status        string     `gorm:"column:status;size:32;comment:'轮次状态'"`
	SnapshotAt    *time.Time `gorm:"column:snapshot_at;comment:'快照时间'"`
	CreatedAt     time.Time  `gorm:"column:created_at;comment:'创建时间'"`
}

func (AirdropRound) TableName() string {
	return "airdrop_rounds"
}

type RoundPoint struct {
	ID            uint64    `gorm:"primaryKey;comment:'轮次积分记录ID'"`
	RoundID       uint64    `gorm:"column:round_id;index;comment:'关联轮次ID'"`
	UserID        uint64    `gorm:"column:user_id;index;comment:'关联用户ID'"`
	Points        int64     `gorm:"column:points;comment:'分配积分'"`
	ClaimedPoints int64     `gorm:"column:claimed_points;comment:'已领取积分'"`
	CreatedAt     time.Time `gorm:"column:created_at;comment:'创建时间'"`
}

func (RoundPoint) TableName() string {
	return "round_points"
}

type Claim struct {
	ID        uint64     `gorm:"primaryKey;comment:'领取记录ID'"`
	RoundID   uint64     `gorm:"column:round_id;index;uniqueIndex:uk_round_wallet;comment:'关联轮次ID'"`
	UserID    uint64     `gorm:"column:user_id;index;comment:'关联用户ID'"`
	Wallet    string     `gorm:"column:wallet;size:64;uniqueIndex:uk_round_wallet;comment:'钱包地址'"`
	Amount    int64      `gorm:"column:amount;comment:'领取积分数量'"`
	TxHash    string     `gorm:"column:tx_hash;size:128;comment:'交易哈希'"`
	Status    string     `gorm:"column:status;size:32;comment:'领取状态'"`
	ClaimedAt *time.Time `gorm:"column:claimed_at;comment:'领取时间'"`
	CreatedAt time.Time  `gorm:"column:created_at;comment:'创建时间'"`
}

func (Claim) TableName() string {
	return "claims"
}
