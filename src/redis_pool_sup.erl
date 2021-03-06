-module(redis_pool_sup).

-behaviour(supervisor).

-export([start_link/1, start_link/2]).

-export([init/1]).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link(PoolName) ->
    start_link(PoolName, '$appenv').

start_link(PoolName, Options) ->
    supervisor:start_link(
      {local, sup_name(PoolName)}, ?MODULE, [PoolName, Options]).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init([PoolName, '$appenv']) ->
    init([PoolName, app_env(PoolName)]);
init([PoolName, PoolOptions]) ->
    {ok, {{one_for_all, 5, 5},
          [{pool, {redis_pool, start_link, [PoolName, PoolOptions]},
            permanent, brutal_kill, worker, [redis_pool]}]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

sup_name(PoolName) ->
    list_to_atom("redis_pool_sup_" ++ atom_to_list(PoolName)).

app_env(Name) ->
    case application:get_env(Name) of
        {ok, Opts} -> Opts;
        undefined -> []
    end.


