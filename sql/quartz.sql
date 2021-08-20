delete from qrtz_fired_triggers;
delete from qrtz_simple_triggers;
delete from qrtz_simprop_triggers;
delete from qrtz_cron_triggers;
delete from qrtz_blob_triggers;
delete from qrtz_triggers;
delete from qrtz_job_details;
delete from qrtz_calendars;
delete from qrtz_paused_trigger_grps;
delete from qrtz_locks;
delete from qrtz_scheduler_state;

drop table qrtz_calendars;
drop table qrtz_fired_triggers;
drop table qrtz_blob_triggers;
drop table qrtz_cron_triggers;
drop table qrtz_simple_triggers;
drop table qrtz_simprop_triggers;
drop table qrtz_triggers;
drop table qrtz_job_details;
drop table qrtz_paused_trigger_grps;
drop table qrtz_locks;
drop table qrtz_scheduler_state;

-- ----------------------------
-- 1、存储每一个已配置的 jobDetail 的详细信息
-- ----------------------------
create table qrtz_job_details (
    sched_name           varchar2(120)    not null,
    job_name             varchar2(200)    not null,
    job_group            varchar2(200)    not null,
    description          varchar2(250)    null,
    job_class_name       varchar2(250)    not null,
    is_durable           varchar2(1)      not null,
    is_nonconcurrent     varchar2(1)      not null,
    is_update_data       varchar2(1)      not null,
    requests_recovery    varchar2(1)      not null,
    job_data             blob             null,
    constraint qrtz_job_details_pk primary key (sched_name, job_name, job_group)
);

comment on table  qrtz_job_details                    is '任务详细信息表';
comment on column qrtz_job_details.sched_name         is '调度名称';
comment on column qrtz_job_details.job_name           is '任务名称';
comment on column qrtz_job_details.job_group          is '任务组名';
comment on column qrtz_job_details.description        is '相关介绍';
comment on column qrtz_job_details.job_class_name     is '执行任务类名称';
comment on column qrtz_job_details.is_durable         is '是否持久化';
comment on column qrtz_job_details.is_nonconcurrent   is '是否并发';
comment on column qrtz_job_details.is_update_data     is '是否更新数据';
comment on column qrtz_job_details.requests_recovery  is '是否接受恢复执行';
comment on column qrtz_job_details.job_data           is '存放持久化job对象';

-- ----------------------------
-- 2、 存储已配置的 Trigger 的信息
-- ----------------------------
create table qrtz_triggers (
    sched_name           varchar2(120)    not null,
    trigger_name         varchar2(200)    not null,
    trigger_group        varchar2(200)    not null,
    job_name             varchar2(200)    not null,
    job_group            varchar2(200)    not null,
    description          varchar2(250)    null,
    next_fire_time       number(13)       null,
    prev_fire_time       number(13)       null,
    priority             number(13)       null,
    trigger_state        varchar2(16)     not null,
    trigger_type         varchar2(8)      not null,
    start_time           number(13)       not null,
    end_time             number(13)       null,
    calendar_name        varchar2(200)    null,
    misfire_instr        number(2)        null,
    job_data             blob             null,
    constraint qrtz_triggers_pk primary key (sched_name, trigger_name, trigger_group),
    constraint qrtz_trigger_to_jobs_fk foreign key (sched_name, job_name, job_group) references qrtz_job_details(sched_name, job_name, job_group)
);

comment on table  qrtz_triggers                    is '触发器详细信息表';
comment on column qrtz_triggers.sched_name         is '调度名称';
comment on column qrtz_triggers.trigger_name       is '触发器的名字';
comment on column qrtz_triggers.trigger_group      is '触发器所属组的名字';
comment on column qrtz_triggers.job_name           is 'qrtz_job_details表job_name的外键';
comment on column qrtz_triggers.job_group          is 'qrtz_job_details表job_group的外键';
comment on column qrtz_triggers.description        is '相关介绍';
comment on column qrtz_triggers.next_fire_time     is '上一次触发时间（毫秒）';
comment on column qrtz_triggers.prev_fire_time     is '下一次触发时间（默认为-1表示不触发）';
comment on column qrtz_triggers.priority           is '优先级';
comment on column qrtz_triggers.trigger_state      is '触发器状态';
comment on column qrtz_triggers.trigger_type       is '触发器的类型';
comment on column qrtz_triggers.start_time         is '开始时间';
comment on column qrtz_triggers.end_time           is '结束时间';
comment on column qrtz_triggers.calendar_name      is '日程表名称';
comment on column qrtz_triggers.misfire_instr      is '补偿执行的策略';
comment on column qrtz_triggers.job_data           is '存放持久化job对象';



-- ----------------------------
-- 3、 存储简单的 Trigger，包括重复次数，间隔，以及已触发的次数
-- ----------------------------
create table qrtz_simple_triggers (
    sched_name           varchar2(120)    not null,
    trigger_name         varchar2(200)    not null,
    trigger_group        varchar2(200)    not null,
    repeat_count         number(7)        not null,
    repeat_interval      number(12)       not null,
    times_triggered      number(10)       not null,
    constraint qrtz_simple_trig_pk primary key (sched_name, trigger_name, trigger_group),
    constraint qrtz_simple_trig_to_trig_fk foreign key (sched_name, trigger_name, trigger_group) references qrtz_triggers(sched_name, trigger_name, trigger_group)
);

comment on table  qrtz_simple_triggers                    is '简单触发器的信息表';
comment on column qrtz_simple_triggers.sched_name         is '调度名称';
comment on column qrtz_simple_triggers.trigger_name       is 'qrtz_triggers表trigger_name的外键';
comment on column qrtz_simple_triggers.trigger_group      is 'qrtz_triggers表trigger_group的外键';
comment on column qrtz_simple_triggers.repeat_count       is '重复的次数统计';
comment on column qrtz_simple_triggers.repeat_interval    is '重复的间隔时间';
comment on column qrtz_simple_triggers.times_triggered    is '已经触发的次数';

-- ----------------------------
-- 4、 存储 Cron Trigger，包括 Cron 表达式和时区信息
-- ---------------------------- 
create table qrtz_cron_triggers (
    sched_name           varchar2(120)    not null,
    trigger_name         varchar2(200)    not null,
    trigger_group        varchar2(200)    not null,
    cron_expression      varchar2(120)    not null,
    time_zone_id         varchar2(80),
    constraint qrtz_cron_trig_pk primary key (sched_name, trigger_name, trigger_group),
    constraint qrtz_cron_trig_to_trig_fk foreign key (sched_name, trigger_name, trigger_group) references qrtz_triggers(sched_name, trigger_name, trigger_group)
);

comment on table  qrtz_cron_triggers                    is 'Cron类型的触发器表';
comment on column qrtz_cron_triggers.sched_name         is '调度名称';
comment on column qrtz_cron_triggers.trigger_name       is 'qrtz_triggers表trigger_name的外键';
comment on column qrtz_cron_triggers.trigger_group      is 'qrtz_triggers表trigger_group的外键';
comment on column qrtz_cron_triggers.cron_expression    is 'cron表达式';
comment on column qrtz_cron_triggers.time_zone_id       is '时区';

-- ----------------------------
-- 5、 Trigger 作为 Blob 类型存储(用于 Quartz 用户用 JDBC 创建他们自己定制的 Trigger 类型，JobStore 并不知道如何存储实例的时候)
-- ---------------------------- 
create table qrtz_blob_triggers (
    sched_name           varchar2(120)    not null,
    trigger_name         varchar2(200)    not null,
    trigger_group        varchar2(200)    not null,
    blob_data            blob null,
    constraint qrtz_blob_trig_pk primary key (sched_name, trigger_name, trigger_group),
    constraint qrtz_blob_trig_to_trig_fk foreign key (sched_name, trigger_name, trigger_group) references qrtz_triggers(sched_name, trigger_name, trigger_group)
);

comment on table  qrtz_blob_triggers                    is 'Blob类型的触发器表';
comment on column qrtz_blob_triggers.sched_name         is '调度名称';
comment on column qrtz_blob_triggers.trigger_name       is 'qrtz_triggers表trigger_name的外键';
comment on column qrtz_blob_triggers.trigger_group      is 'qrtz_triggers表trigger_group的外键';
comment on column qrtz_blob_triggers.blob_data          is '存放持久化Trigger对象';

-- ----------------------------
-- 6、 以 Blob 类型存储存放日历信息， quartz可配置一个日历来指定一个时间范围
-- ---------------------------- 
create table qrtz_calendars (
    sched_name           varchar2(120)    not null,
    calendar_name        varchar2(200)    not null,
    calendar             blob             not null,
    constraint qrtz_calendars_pk primary key (sched_name, calendar_name)
);

comment on table  qrtz_calendars                    is '日历信息表';
comment on column qrtz_calendars.sched_name         is '调度名称';
comment on column qrtz_calendars.calendar_name      is '日历名称';
comment on column qrtz_calendars.calendar           is '存放持久化calendar对象';

-- ----------------------------
-- 7、 存储已暂停的 Trigger 组的信息
-- ---------------------------- 
create table qrtz_paused_trigger_grps (
    sched_name           varchar2(120)    not null,
    trigger_group        varchar2(200)    not null,
    constraint qrtz_paused_trig_grps_pk primary key (sched_name, trigger_group)
);

comment on table  qrtz_paused_trigger_grps                    is '暂停的触发器表';
comment on column qrtz_paused_trigger_grps.sched_name         is '调度名称';
comment on column qrtz_paused_trigger_grps.trigger_group      is 'qrtz_triggers表trigger_group的外键';

-- ----------------------------
-- 8、 存储与已触发的 Trigger 相关的状态信息，以及相联 Job 的执行信息
-- ---------------------------- 
create table qrtz_fired_triggers (
    sched_name           varchar2(120)    not null,
    entry_id             varchar2(95)     not null,
    trigger_name         varchar2(200)    not null,
    trigger_group        varchar2(200)    not null,
    instance_name        varchar2(200)    not null,
    fired_time           number(13)       not null,
    sched_time           number(13)       not null,
    priority             number(13)       not null,
    state                varchar2(16)     not null,
    job_name             varchar2(200)    null,
    job_group            varchar2(200)    null,
    is_nonconcurrent     varchar2(1)      null,
    requests_recovery    varchar2(1)      null,
    constraint qrtz_fired_trigger_pk primary key (sched_name, entry_id)
);

comment on table  qrtz_fired_triggers                      is '已触发的触发器表';
comment on column qrtz_fired_triggers.sched_name           is '调度名称';
comment on column qrtz_fired_triggers.entry_id             is '调度器实例id';
comment on column qrtz_fired_triggers.trigger_name         is 'qrtz_triggers表trigger_name的外键';
comment on column qrtz_fired_triggers.trigger_group        is 'qrtz_triggers表trigger_group的外键';
comment on column qrtz_fired_triggers.instance_name        is '调度器实例名';
comment on column qrtz_fired_triggers.fired_time           is '触发的时间';
comment on column qrtz_fired_triggers.sched_time           is '定时器制定的时间';
comment on column qrtz_fired_triggers.priority             is '优先级';
comment on column qrtz_fired_triggers.state                is '状态';
comment on column qrtz_fired_triggers.job_name             is '任务名称';
comment on column qrtz_fired_triggers.job_group            is '任务组名';
comment on column qrtz_fired_triggers.is_nonconcurrent     is '是否并发';
comment on column qrtz_fired_triggers.requests_recovery    is '是否接受恢复执行';

-- ----------------------------
-- 9、 存储少量的有关 Scheduler 的状态信息，假如是用于集群中，可以看到其他的 Scheduler 实例
-- ---------------------------- 
create table qrtz_scheduler_state (
    sched_name           varchar2(120)    not null,
    instance_name        varchar2(200)    not null,
    last_checkin_time    number(13)       not null,
    checkin_interval     number(13)       not null,
    constraint qrtz_scheduler_state_pk primary key (sched_name, instance_name)
);

comment on table  qrtz_scheduler_state                     is '调度器状态表';
comment on column qrtz_scheduler_state.sched_name          is '调度名称';
comment on column qrtz_scheduler_state.instance_name       is '实例名称';
comment on column qrtz_scheduler_state.last_checkin_time   is '上次检查时间';
comment on column qrtz_scheduler_state.checkin_interval    is '检查间隔时间';

-- ----------------------------
-- 10、 存储程序的悲观锁的信息(假如使用了悲观锁)
-- ---------------------------- 
create table qrtz_locks (
    sched_name           varchar2(120)    not null,
    lock_name            varchar2(40)     not null,
    constraint qrtz_locks_pk primary key (sched_name, lock_name)
);

comment on table  qrtz_locks                    is '存储的悲观锁信息表';
comment on column qrtz_locks.sched_name         is '调度名称';
comment on column qrtz_locks.lock_name          is '悲观锁名称';

-- ----------------------------
-- 11、 Quartz集群实现同步机制的行锁表
-- ---------------------------- 
create table qrtz_simprop_triggers (
    sched_name           varchar2(120)    not null,
    trigger_name         varchar2(200)    not null,
    trigger_group        varchar2(200)    not null,
    str_prop_1           varchar2(512)    null,
    str_prop_2           varchar2(512)    null,
    str_prop_3           varchar2(512)    null,
    int_prop_1           number(10)       null,
    int_prop_2           number(10)       null,
    long_prop_1          number(13)       null,
    long_prop_2          number(13)       null,
    dec_prop_1           numeric(13,4)    null,
    dec_prop_2           numeric(13,4)    null,
    bool_prop_1          varchar2(1)      null,
    bool_prop_2          varchar2(1)      null,
    constraint qrtz_simprop_trig_pk primary key (sched_name, trigger_name, trigger_group),
    constraint qrtz_simprop_trig_to_trig_fk foreign key (sched_name, trigger_name, trigger_group) references qrtz_triggers(sched_name, trigger_name, trigger_group)
);

comment on table  qrtz_simprop_triggers                    is '同步机制的行锁表';
comment on column qrtz_simprop_triggers.sched_name         is '调度名称';
comment on column qrtz_simprop_triggers.trigger_name       is 'qrtz_triggers表trigger_name的外键';
comment on column qrtz_simprop_triggers.trigger_group      is 'qrtz_triggers表trigger_group的外键';
comment on column qrtz_simprop_triggers.str_prop_1         is 'String类型的trigger的第一个参数';
comment on column qrtz_simprop_triggers.str_prop_2         is 'String类型的trigger的第二个参数';
comment on column qrtz_simprop_triggers.str_prop_3         is 'String类型的trigger的第三个参数';
comment on column qrtz_simprop_triggers.int_prop_1         is 'int类型的trigger的第一个参数';
comment on column qrtz_simprop_triggers.int_prop_2         is 'int类型的trigger的第二个参数';
comment on column qrtz_simprop_triggers.long_prop_1        is 'long类型的trigger的第一个参数';
comment on column qrtz_simprop_triggers.long_prop_2        is 'long类型的trigger的第二个参数';
comment on column qrtz_simprop_triggers.dec_prop_1         is 'decimal类型的trigger的第一个参数';
comment on column qrtz_simprop_triggers.dec_prop_2         is 'decimal类型的trigger的第二个参数';
comment on column qrtz_simprop_triggers.bool_prop_1        is 'Boolean类型的trigger的第一个参数';
comment on column qrtz_simprop_triggers.bool_prop_2        is 'Boolean类型的trigger的第二个参数';

create index idx_qrtz_j_req_recovery on qrtz_job_details(sched_name, requests_recovery);
create index idx_qrtz_j_grp on qrtz_job_details(sched_name, job_group);

create index idx_qrtz_t_j on qrtz_triggers(sched_name, job_name, job_group);
create index idx_qrtz_t_jg on qrtz_triggers(sched_name, job_group);
create index idx_qrtz_t_c on qrtz_triggers(sched_name, calendar_name);
create index idx_qrtz_t_g on qrtz_triggers(sched_name, trigger_group);
create index idx_qrtz_t_state on qrtz_triggers(sched_name, trigger_state);
create index idx_qrtz_t_n_state on qrtz_triggers(sched_name, trigger_name, trigger_group, trigger_state);
create index idx_qrtz_t_n_g_state on qrtz_triggers(sched_name, trigger_group, trigger_state);
create index idx_qrtz_t_next_fire_time on qrtz_triggers(sched_name, next_fire_time);
create index idx_qrtz_t_nft_st on qrtz_triggers(sched_name, trigger_state, next_fire_time);
create index idx_qrtz_t_nft_misfire on qrtz_triggers(sched_name, misfire_instr, next_fire_time);
create index idx_qrtz_t_nft_st_misfire on qrtz_triggers(sched_name, misfire_instr, next_fire_time, trigger_state);
create index idx_qrtz_t_nft_st_misfire_grp on qrtz_triggers(sched_name, misfire_instr, next_fire_time, trigger_group, trigger_state);

create index idx_qrtz_ft_trig_inst_name on qrtz_fired_triggers(sched_name, instance_name);
create index idx_qrtz_ft_inst_job_req_rcvry on qrtz_fired_triggers(sched_name, instance_name, requests_recovery);
create index idx_qrtz_ft_j_g on qrtz_fired_triggers(sched_name, job_name, job_group);
create index idx_qrtz_ft_jg on qrtz_fired_triggers(sched_name, job_group);
create index idx_qrtz_ft_t_g on qrtz_fired_triggers(sched_name, trigger_name, trigger_group);

create index idx_qrtz_ft_tg on qrtz_fired_triggers(sched_name, trigger_group);

commit;