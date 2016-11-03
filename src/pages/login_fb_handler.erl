-module(login_fb_handler).

-export([init/2]).

-include("geo_app.hrl").

init(Req0, Opts) ->
	_Method = cowboy_req:method(Req0),
	ReqMap = cowboy_req:match_qs([{email, [], undefined}, 
                                   {facebookid, [], undefined}], Req0),
    %%TODO: could raise exception, need validation rules
    #{email := Email, facebookid := FbID} = ReqMap,
    Res = geo_app_sql:auth_fb(Email, FbID),
    Req1 = process_login(Res, Req0),
	{ok, Req1, Opts}.

process_login([], Req) ->
    RawJSON = mochijson2:encode({struct, [{sucess, false}, {error_code, 1}, {error, <<"not exist or wrong login/pass pair">>}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_login([_User=#user{id = UserID}|_Tail], Req) ->
    %% need handle user sessions
    %% in some cases when unique index not set we could get duplicate, so Tail must be []
    RawJSON = mochijson2:encode({struct, [{sucess, true}, {user_id, UserID}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_login({error, _}, Req) ->
    %% mysql error
    RawJSON = mochijson2:encode({struct, [{sucess, false}, {error_code, 2}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req).
