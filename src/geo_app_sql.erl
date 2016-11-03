-module(geo_app_sql).

-export([init/0, new_user/4, auth/2, auth_fb/2, username/1]).

-include("geo_app.hrl").

init() ->
    %%init statements
    AuthSQL = <<"SELECT id FROM users WHERE password = ? AND email = ?">>, 
    emysql:prepare(auth, AuthSQL),

    AuthFBSQL = <<"SELECT id FROM users WHERE facebookid = ? AND email = ?">>, 
    emysql:prepare(authfb, AuthFBSQL),

    NewUserSQL = <<"INSERT INTO `users` (`email`, `password`, `facebookid`, `username`) VALUES (?, ?, ?, ?);">>,
    emysql:prepare(new_user, NewUserSQL),

    UsernameSQL = <<"SELECT username FROM users WHERE id = ?">>,
    emysql:prepare(username, UsernameSQL),
    ok.

new_user(Login, Email, Pass, FbID) ->
    case catch emysql:execute(?MYSQL_POOL, new_user, [Email, Pass, FbID, Login]) of
        {'EXIT', Reason} ->
            lager:error("MYSQL: failed add new user: ~p, reason: ~p", [Email, Reason]),
            {error, failed};
        {ok_packet, _, _, UserID, _, _, _} ->
            {ok, UserID};
        {error_packet, _, 1062, _, _} ->
            {error, exist}
    end.
    

auth(Email, Pass) ->
    case catch emysql:execute(?MYSQL_POOL, auth, [Pass, Email]) of
        {'EXIT', Reason} ->
            lager:error("MYSQL: failed auth user: ~p, reason: ~p", [Email, Reason]),
            {error, failed};
        Res ->
            emysql:as_record(Res, user, record_info(fields, user))
    end.

auth_fb(Email, FbID) ->
    case catch emysql:execute(?MYSQL_POOL, authfb, [FbID, Email]) of
        {'EXIT', Reason} ->
            lager:error("MYSQL: failed auth user: ~p, reason: ~p", [Email, Reason]),
            {error, failed};
        Res ->
            emysql:as_record(Res, user, record_info(fields, user))
    end.

username(UserID) ->
    case catch emysql:execute(?MYSQL_POOL, username, [UserID]) of
        {'EXIT', Reason} ->
            lager:error("MYSQL: failed get username user: ~p, reason: ~p", [UserID, Reason]),
            {error, failed};
        Res ->
            emysql:as_record(Res, username, record_info(fields, username))
    end.



