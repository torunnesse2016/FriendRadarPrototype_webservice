-module(update_location_handler).

-export([init/2]).

-include("geo_app.hrl").

init(Req0, Opts) ->
	_Method = cowboy_req:method(Req0),
	ReqMap = cowboy_req:match_qs([{email, [], undefined}, 
                                  {longitude, [], undefined},
                                  {latitude, [], undefined},
                                  {user_id, [], undefined}], Req0),
    %%TODO: could raise exception, need validation rules
    %%TODO: check if user exist(session handling)
    #{longitude := Longitude, latitude := Latitude, user_id := UserID} = ReqMap,
    lager:info("UPDATE LOCATION: ~p", [ReqMap]),
    UserName = case geo_app_sql:username(UserID) of
                   {error, _} -> <<"None">>;
                   [] -> <<"None">>;
                   [User=#username{username = undefined}] -> <<"None">>;
                   [User=#username{username = U}] -> U
    end,
    Res = geo_app_redis:add_location(<<UserName/binary, ":", UserID/binary>>, Latitude, Longitude),
    Req1 = process_update_location(Res, Req0),
	{ok, Req1, Opts}.

process_update_location({ok, <<"1">>}, Req) ->
    %% inserted new
    RawJSON = mochijson2:encode({struct, [{sucess, true}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_update_location({ok, <<"0">>}, Req) ->
    %% updated 
    RawJSON = mochijson2:encode({struct, [{sucess, true}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_update_location({error, Reason}, Req) ->
    lager:error("REDIS: error: ~p", [Reason]),
    RawJSON = mochijson2:encode({struct, [{sucess, false}, {error_code, 2}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req).
