%% pools
-define(MYSQL_POOL, mysql_pool).
-define(REDIS_POOL, redis_pool).

-define(WORLD_KEY, <<"mini-world">>).

%% mysql db mapper, swap into 1 record
-record(user, {id}).
-record(username, {username}).
