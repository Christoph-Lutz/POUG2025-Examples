create or replace package pkg_tc_restart as
    procedure send(p_pipe varchar2, p_msg in varchar2);
    procedure receive(p_pipe varchar2);
    function test(p_n number) return number;
end pkg_tc_restart;
/


create or replace package body pkg_tc_restart as
    g_pass number := 0;

    procedure send(p_pipe in varchar2, p_msg in varchar2) as
        l_status number;
    begin
        dbms_pipe.pack_message(p_msg);
        l_status := dbms_pipe.send_message(p_pipe);
        if l_status != 0 then
            raise_application_error(-20001, 'Pipe send failed');
        end if;
    end send;

    procedure receive(p_pipe in varchar2) as
        l_result number;
        l_msg varchar2(32);
        l_max number;
        l_nr number;
    begin
        if p_pipe = 'PIPE_STMT_SMALL' then
            loop
                l_result := dbms_pipe.receive_message(
                              pipename=> p_pipe,
                              timeout => DBMS_PIPE.maxwait);
                if l_result = 0 then
                    dbms_pipe.unpack_message(l_msg);
                    dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' SMALL: l_msg: '||l_msg);
                else
                    raise_application_error('-20002', 'Pipe receive failed. Return: ' ||l_result);
                end if;

                if l_msg = 'CONTINUE' then
                    select n into l_max from tc_restart where v = 'HIGHVAL';
                    dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' SMALL: before l_max: ' ||l_max);
                    update tc_restart set n = n+1 where v = 'HIGHVAL';
                    -- update tc_restart set n = n+1 where v = 'LOWVAL';
                    -- l_nr := to_number(replace(l_msg, 'CONTINUE_', '')) + 1;
                    -- update tc_restart set n = l_nr + (0.0000001 * l_i) where trunc(n) = l_nr;
                    commit;
                    select n into l_max from tc_restart where v = 'HIGHVAL';
                    dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' SMALL: after l_max: ' ||l_max);
                    send('PIPE_STMT_LARGE', 'CONTINUE');
                end if;

                if l_msg = 'CONTINUE2' then
                    update tc_restart set n = 999 where n = 1;
                    -- delete from tc_restart where n = 1;
                    commit;
                    send('PIPE_STMT_LARGE', 'CONTINUE');
                end if;

                exit when l_msg = 'STOP';
            end loop;
       else
           l_result := dbms_pipe.receive_message(
                         pipename=> p_pipe,
                         timeout => DBMS_PIPE.maxwait);
            if l_result = 0 then
                dbms_pipe.unpack_message(l_msg);
                dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' LARGE: l_msg: '||l_msg);
            else
                raise_application_error('-20002', 'Pipe receive failed. Return: ' ||l_result);
            end if;
       end if;
    end receive;

    function test(p_n number) return number as
        l_ret number;
    begin
        dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' p_n: '||p_n);
        -- dbms_session.sleep(1);
        if g_pass = 0 then
            dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' LARGE: send (p_n: '||p_n  ||')');
            send('PIPE_STMT_SMALL', 'CONTINUE2');

            receive('PIPE_STMT_LARGE');
            dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' LARGE: received (p_n: '||p_n  ||')');
        end if;

        if g_pass = 3 then
            send('PIPE_STMT_SMALL', 'CONTINUE2');
            receive('PIPE_STMT_LARGE');
        end if;

        if p_n = 1 then
            g_pass := g_pass + 1;
            l_ret := mod(g_pass, 2);
        else
            l_ret := p_n;
        end if;

        dbms_output.put_line(to_char(systimestamp, 'hh24:mi:ss.ff9') ||' LARGE: ret (g_pass: ' ||g_pass ||',' ||'l_ret: '||l_ret ||')');
        return l_ret;
        -- return p_n;
    end test;

end pkg_tc_restart;
/

