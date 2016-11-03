-module(signup_fb_handler).

-export([init/2]).

init(Req0, Opts) ->
	_Method = cowboy_req:method(Req0),
	ReqMap = cowboy_req:match_qs([{email, [], undefined}, 
                                   {username, [], undefined}, 
                                   {facebookid, [], undefined}], Req0),
    %%TODO: could raise exception, need validation rules
    #{email := Email, username := UserName, facebookid := FbID} = ReqMap,
    Res = geo_app_sql:new_user(UserName, Email, null, FbID),
    Req1 = process_signup(Res, Req0),
	{ok, Req1, Opts}.

process_signup({ok, UserID}, Req) ->
    RawJSON = mochijson2:encode({struct, [{sucess, true}, {user_id, UserID}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_signup({error, exist}, Req) ->
    %% user exist with this email try to pair 2 accoutns into 1 ?
    RawJSON = mochijson2:encode({struct, [{sucess, false}, {error_code, 1}, {error, <<"already exist">>}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req);
process_signup({error, _}, Req) ->
    %% mysql error
    RawJSON = mochijson2:encode({struct, [{sucess, false}, {error_code, 2}]}),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RawJSON, Req).
