-module(geo_app_redis).

-export([add_location/3, radius/4]).

-include("geo_app.hrl").

%% @doc add/update location for certain user_id
add_location(UserData, Lat, Long) when is_binary(UserData), is_binary(Lat), is_binary(Long) ->
    poolboy:transaction(?REDIS_POOL, fun(Worker) -> 
        eredis:q(Worker, ["GEOADD", ?WORLD_KEY, Long, Lat, ["udata:", UserData]])
    end).

%% @doc find nearest users
radius(Lat, Long, RType, Radius) when is_binary(Lat), is_binary(Long), is_binary(RType), is_binary(Radius) ->
    poolboy:transaction(?REDIS_POOL, fun(Worker) -> 
        eredis:q(Worker, ["GEORADIUS", ?WORLD_KEY, Long, Lat, Radius, RType, "WITHDIST", "WITHCOORD"])
    end).
