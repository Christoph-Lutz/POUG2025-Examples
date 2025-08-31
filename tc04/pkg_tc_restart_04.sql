/* 
 * Purpose:
 *   Test case to demonstrate Oracle write consistency behavior by
 *   simulating a scenario with non-deterministic query results.
 *
 *   The test case requires two sessions that are synchronized via
 *   dbms_pipe to simulate the following scenario:
 *
 *   Session 1: Start an update using a non-deterministic function
 *              that behaves as follows:
 *               - On pass=1 (UNLOCKED)  : return 1
 *               - On pass=2 (LOCKED)    : return 0
 *               - On pass=3 (ALL LOCKED): return 1
 *
 *   Session 2: Update a row needed by the update in session 1 to
 *              trigger a restart. After the restart in session 1, 
 *              also modify a row that the update in session 1 does 
 *              not lock in the LOCKED phase, but which it does lock
 *              in the ALL LOCKED phase due to the non-deterministic
 *              behavior.
 *
 *   The update in session 1 will fail with an ORA-600[13030] error,
 *   which means, that it didn't get a "stable set of rows".
 * 
 *   You can enable DML tracing to trace the Oracle three pass 
 *   algorithm like so:
 *     alter session set events 'trace[dml] disk=highest';
 *
 * Author:
 *   Christoph Lutz
 *
 * Date:
 *   Jan-16 2025
 *
 * Tested on:
 *   Oracle 19.26
 * 
 * Usage:
 *   Create a test table and load the plsql package with the 
 *   test code:
 *
 *   @setup.sql
 *
 *   When setup is complete, open two new sessions and start 
 *   the test procedures (ses2 must be started first):
 *  
 *   Session 2: @ses2.sql
 *   Session 1: @ses1.sql
 *
 * Notes:
 *   To enable printing debug output change the G_DEBUG flag.
 *   Debug output will be written to the alert log.
 */
create or replace package pkg_tc_restart_04 as
    G_DEBUG      boolean               :=  TRUE;
    G_PASS       pls_integer           :=  1;
    PIPE_SES1    constant varchar2(32) := 'PIPE_SES1';
    PIPE_SES2    constant varchar2(32) := 'PIPE_SES2';
    CMD_UPDATE1  constant varchar2(32) := 'UPDATE1';
    CMD_UPDATE2  constant varchar2(32) := 'UPDATE2';
    CMD_CONTINUE constant varchar2(32) := 'CONTINUE';
    CMD_STOP     constant varchar2(32) := 'STOP';
    procedure    reset;
    procedure    start_ses1;
    procedure    start_ses2;
    procedure    stop_ses2; 
    function     test_func(p_n number) return number;
end pkg_tc_restart_04;
/

create or replace package body pkg_tc_restart_04 as

    procedure reset as
    begin
        dbms_session.reset_package;
        dbms_pipe.purge(PIPE_SES1);
        dbms_pipe.purge(PIPE_SES2);
    end reset;

    procedure debug(p_msg varchar2) as
    begin
        if G_DEBUG then
            sys.dbms_system.ksdwrt(sys.dbms_system.alert_file, p_msg);
        end if;
    end debug;

    procedure send(p_pipe in varchar2, p_msg in varchar2) as
        l_status number;
    begin
        dbms_pipe.pack_message(p_msg);
        l_status := dbms_pipe.send_message(p_pipe);
        if l_status != 0 then
            raise_application_error(-20001, 'Pipe send failed');
        end if;
    end send;

    procedure receive(p_pipe in varchar2, p_msg out varchar2) as
        l_res number;
    begin
        l_res := dbms_pipe.receive_message(p_pipe, DBMS_PIPE.maxwait);
        if l_res = 0 then
            dbms_pipe.unpack_message(p_msg);
        else
            raise_application_error('-20002', 'Pipe receive failed. Return: ' ||l_res);
        end if;
    end receive;

    function test_func(p_n number) return number as
        l_msg varchar2(32);
        l_ret number;
    begin
        debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses1: test_func: entry: p_n='||p_n||' pass='||G_PASS);

        /* 
         * On the first pass (before entering phase UNLOCKED), 
         * notify ses2 to execute a small update (of row 4). 
         * This will trigger a restart in ses1.
         */
        if G_PASS = 1 then
            debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses1: test_func: send: p_n='||p_n||' pass='||G_PASS);
            send(PIPE_SES2, CMD_UPDATE1);

            /* Note: no need to check what msg exactly we're receiving here. */
            receive(PIPE_SES1, l_msg);
            debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses1: test_func: received: l_msg='||l_msg||' pass='||G_PASS);
        end if;

        /*
         * On the third pass (before entering phase ALL LOCKED),
         * notify ses2 to execute another small update (of row 1,
         * for which test_func() won't return a deterministic
         * result). This will cause an ORA-600 13030, because 
         * row 1 did not get locked in phase LOCKED and so ses2
         * was able to modify it before entering phase ALL LOCKED.
         */
        if G_PASS = 3 then
            debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses1: test_func: send: p_n='||p_n||' pass='||G_PASS);
            send(PIPE_SES2, CMD_UPDATE2);

            /* Note: no need to check what msg exactly we're receiving here. */
            receive(PIPE_SES1, l_msg);
            debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses1: test_func: received: l_msg='||l_msg||' pass='||G_PASS);
        end if;

        /* 
         * Simulate a non-deterministic function result.
         * This has the following effect:
         *   - On pass=1 (UNLOCKED)  : return 1
         *   - On pass=2 (LOCKED)    : return 0
         *   - On pass=3 (ALL LOCKED): return 1
         * Due to the return 0 in pass 2, the row with
         * n=1 will not get locked. However, due to the
         * return 1 in pass 3, Oracle will find the row
         * with n=1 again in the ALL LOCKED phase  and 
         * attempt to update it, which will fail, because 
         * the result set is not stable. Hope this all 
         * makes sense. :-)
         */
        if p_n = 1 then
            l_ret := mod(G_PASS, 2);
            G_PASS := G_PASS+1;
        else
            l_ret := p_n;
        end if;

        debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses1: ret='||l_ret ||' pass=' ||G_PASS);

        return l_ret;
    end test_func;

    procedure start_ses1 as
    begin
        update tc_restart t set t.n = n+1 where pkg_tc_restart_04.test_func(t.n) in (1,2,3,4);
    end start_ses1;

    procedure start_ses2 as
        l_n number;
        l_msg varchar2(32);
    begin
        loop
            receive(PIPE_SES2, l_msg);

            if l_msg = CMD_UPDATE1 then
                debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses2: updating table ...');
                update tc_restart set n = n+1 where v = 'HIGHVAL' returning n into l_n;
                commit;
                debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses2: update complete: n=' ||l_n);
                send(PIPE_SES1, CMD_CONTINUE);
            end if;

            if l_msg = CMD_UPDATE2 then
                debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses2: updating table ...');
                update tc_restart set n = 999 where n = 1 returning n into l_n;
                commit;
                debug(to_char(systimestamp, 'hh24:mi:ss.ff9') ||': ses2: update complete: n=' ||l_n);
                send(PIPE_SES1, CMD_CONTINUE);
            end if;

        exit when l_msg = CMD_STOP;
        end loop;
    end start_ses2;

    procedure stop_ses2 as
    begin
        send(PIPE_SES2, CMD_STOP);
    end stop_ses2;

end pkg_tc_restart_04;
/

show error
