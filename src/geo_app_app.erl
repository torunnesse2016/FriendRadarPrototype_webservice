%%%-------------------------------------------------------------------
%% @doc geo_app public API
%% @end
%%%-------------------------------------------------------------------

-module(geo_app_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    
    %% user rebar3 auto instead
    ok = sync:go(),
    sync:log(all),

    %% init mysql statements
    geo_app_sql:init(),

    Res = geo_app_sup:start_link(),

    %% start cowboy handler
    Dispatch = cowboy_router:compile([
		{'_', [
			{"/", index_handler, []},
			{"/signup", signup_handler, []},
			{"/signup_fb", signup_fb_handler, []},
			{"/login", login_handler, []},
			{"/login_fb", login_fb_handler, []},
            {"/update_location", update_location_handler, []},
			{"/find_nearest", find_nearest_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, 10, [{port, 81}], #{
		env => #{dispatch => Dispatch}
	}),

    %% possible race condition between cowboy and other libs(move to seprate supervisor)
    Res.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
