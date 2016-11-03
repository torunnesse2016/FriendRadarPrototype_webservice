-module(find_nearest_handler).

-export([init/2]).

init(Req0, Opts) ->
	_Method = cowboy_req:method(Req0),
	ReqMap = cowboy_req:match_qs([{email, [], undefined}, 
                                  {longitude, [], undefined},
                                  {latitude, [], undefined},
                                  {distance, [], undefined},
                                  {dist_unit, [], undefined},
                                  {user_id, [], undefined}], Req0),
    %%TODO: could raise exception, need validation rules
    %%TODO: check if user exist(session handling)
    %%TODO: validation for dist_units
    #{longitude := Longitude, latitude := Latitude, 
        user_id := _UserID, distance := Distance, dist_unit := DistUnit} = ReqMap,
    lager:info("RADIUS REQ: ~p", [ReqMap]),
    Res = geo_app_redis:radius(Latitude, Longitude, DistUnit, Distance),
    Req1 = process_radius(Res, Req0),
	{ok, Req1, Opts}.

process_radius({ok, Res}, Req) ->
    Formater = fun(Item, Acc) ->
        [<<"udata:", UserData/binary>>, Distance, [Long, Lat]] = Item,
        {UserName, UserId} = parse_udata(UserData, <<>>),   
        T = {struct, [{user_id, UserId}, {username, UserName}, {distance, Distance}, 
                   {longitude, Long}, {latitude, Lat}]},
         [T|Acc]
    end,
    NewList = lists:foldl(Formater, [], Res),
    RawJSON = mochijson2:encode({struct, [{sucess, true}, {data, NewList}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_radius({error, Reason}, Req) ->
    lager:error("REDIS: error: ~p", [Reason]),
    RawJSON = mochijson2:encode({struct, [{sucess, false}, {error_code, 2}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req).

parse_udata(<<>>, Acc) -> {Acc, 0};
parse_udata(<<":", Rest/binary>>, Acc) ->
    {Acc, Rest};
parse_udata(<<A:1/binary, Rest/binary>>, Acc) -> 
    parse_udata(Rest, <<Acc/binary, A/binary>>).
