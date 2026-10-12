--
-- PostgreSQL database dump
--

\restrict zplaCOwKaHxMbMKFFS2zPMyJRn9FW5NZIf1MDDIGMZHiN8SqF3y772pCcpDMkYl

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: presence; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.presence AS ENUM (
    'todo',
    'done',
    'redo'
);


--
-- Name: register_member; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.register_member AS (
	id uuid,
	name text,
	first_name text,
	last_name text,
	birth date,
	color text,
	email text,
	phone text
);


--
-- Name: register_product; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.register_product AS (
	id uuid,
	member_id uuid,
	summary text,
	length integer,
	start date,
	stop date
);


--
-- Name: role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.role AS ENUM (
    'admin',
    'user'
);


--
-- Name: sync_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sync_status AS ENUM (
    'synced',
    'syncing',
    'deleting',
    'pending',
    'error'
);


--
-- Name: sync_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sync_type AS ENUM (
    'meeting',
    'session'
);


--
-- Name: add_meeting(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_meeting(p_meeting jsonb) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
  v_meeting_id uuid;
begin
  -- Inserting meeting into meetings table
  insert into public.meetings (
    id,
    product_id, 
    start, 
    stop, 
    recurrence_id, 
    recurrence_rule
  )
  values (
    (p_meeting->>'id')::uuid,
    (p_meeting->>'product_id')::uuid,
    (p_meeting->>'start')::timestamptz, 
    (p_meeting->>'stop')::timestamptz,
    case 
      when p_meeting ? 'recurrence_id' 
      then (p_meeting->>'recurrence_id')::uuid 
      else null 
    end,
    case 
      when p_meeting ? 'recurrence_rule' 
      then (p_meeting->>'recurrence_rule')::text 
      else null 
    end
  )
  returning id into v_meeting_id;

  return v_meeting_id;
end;
$$;


--
-- Name: add_member(jsonb, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_member(p_member jsonb, p_user_id uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
  p_member_id uuid;
begin
  -- creating member into members
  insert into public.members (
    id, name, first_name, last_name, birth, color
  ) values (
    coalesce((p_member->>'id')::uuid, gen_random_uuid()),
    (p_member->>'name')::text, 
    (p_member->>'first_name')::text, 
    (p_member->>'last_name')::text, 
    (p_member->>'birth')::date,
    (p_member->>'color')::text
  ) returning id into p_member_id;
  -- creating member link into users
  insert into public.users (auth_id, member_id)
  values (p_user_id, p_member_id);
  -- returning member uuid 
  return p_member_id;
end;
$$;


--
-- Name: add_product(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_product(p_product jsonb) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
  p_product_id uuid;
begin
  -- creating product into products
  insert into public.products (
    member_id, summary, length, start, stop
  ) values (
    (p_product->>'member_id')::uuid,
    (p_product->>'summary')::text,
    (p_product->>'length')::int4, 
    (p_product->>'start')::date, 
    (p_product->>'stop')::date
  ) returning id into p_product_id;
  -- returning product uuid 
  return p_product_id;
end;
$$;


--
-- Name: add_session(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_session(p_session jsonb) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
  v_session_id uuid;
begin
  -- Inserting session into sessions table
  insert into public.sessions (
    product_id, 
    start, 
    stop, 
    presence
  )
  values (
    (p_session->>'product_id')::uuid,
    (p_session->>'start')::timestamptz, 
    (p_session->>'stop')::timestamptz,
    (p_session->>'presence')::boolean
  )
  returning id into v_session_id;

  return v_session_id;
end;
$$;


--
-- Name: custom_access_token_hook(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.custom_access_token_hook(event jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE
    AS $$
declare
  claims jsonb;
  v_role text;
begin
  select auth_role into v_role
    from public.logins
   where auth_id = (event->>'user_id')::uuid;

  claims := event->'claims';
  claims := jsonb_set(claims, '{auth_role}', to_jsonb(v_role));

  return jsonb_set(event, '{claims}', claims);
end;
$$;


--
-- Name: del_meeting(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.del_meeting(p_meeting_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  v_recurrence_id text;
begin
  select recurrence_id into v_recurrence_id
  from public.meetings
  where id = p_meeting_id;

  if found then
    update public.meetings
    set recurrence_id = v_recurrence_id
    where recurrence_id = p_meeting_id::text;
  end if;

  delete from public.meetings
  where id = p_meeting_id;

  -- if not found then
  --   raise notice 'Meeting with ID % not found for deletion.', p_meeting_id;
  -- end if;
end;
$$;


--
-- Name: del_member(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.del_member(p_member_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  -- removing member from members
  delete from public.members
  where id = p_member_id;
  -- removing member link from users
  -- delete from public.users
  -- where member_id = p_member_id;
end;
$$;


--
-- Name: del_product(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.del_product(p_product_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  -- removing product from products
  delete from public.products
  where id = p_product_id;
end;
$$;


--
-- Name: del_session(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.del_session(p_session_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  delete from public.sessions
  where id = p_session_id;

  if not found then
    raise notice 'Session with ID % not found for deletion.', p_meeting_id;
  end if;
end;
$$;


--
-- Name: gcal_enqueue_delete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gcal_enqueue_delete() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  update gcal
     set gcal_sync_status = 'deleting',
         gcal_sync_error  = null
   where id = old.id;
  return null;
end $$;


--
-- Name: gcal_enqueue_upsert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gcal_enqueue_upsert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into gcal (id, gcal_type, gcal_sync_status, gcal_sync_error)
  values (new.id, tg_argv[0]::sync_type, 'pending', null)
  on conflict (id) do update
    set gcal_sync_status = 'pending',
        gcal_sync_error  = null;
  return null;  -- nei trigger AFTER il valore di ritorno è ignorato
end $$;


--
-- Name: gcal_member_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gcal_member_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  update gcal
     set gcal_sync_status = 'pending',
         gcal_sync_error  = null
   where gcal_sync_status <> 'deleting'
     and id in (
       select m.id
         from meetings m
         join products p on p.id = m.product_id
        where p.member_id = new.id
       union all
       select pr.id
         from presences pr
         join products p on p.id = pr.product_id
        where p.member_id = new.id
     );
  return null;
end $$;


--
-- Name: gcal_product_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gcal_product_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  update gcal
     set gcal_sync_status = 'pending',
         gcal_sync_error  = null
   where gcal_sync_status <> 'deleting'
     and id in (
       select id from meetings  where "productId" = new.id
       union all
       select id from presences where "productId" = new.id
     );
  return null;
end $$;


--
-- Name: gcal_sync(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gcal_sync() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  if coalesce(current_setting('request.jwt.claims', true)::jsonb ->> 'role', '') = 'service_role' then
    return null;
  end if;

  if exists (select 1 from new_rows where gcal_sync_status in ('pending', 'deleting')) then
    perform net.http_post(
      url     := 'https://nuxbtafdllyeeiozexzi.supabase.co/functions/v1/gcal-sync',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets
                                       where name = 'service_role_key'),
        'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets
                          where name = 'cron_secret')
      ),
      body    := '{}'::jsonb
    );
  end if;
  return null;
end $$;


--
-- Name: get_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_admin() RETURNS TABLE(auth_id uuid, auth_role public.role)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select l.auth_id, l.auth_role
  from public.logins l
  where l.auth_id = (select auth.uid())
    and l.auth_role = 'admin'
$$;


--
-- Name: get_meetings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_meetings() RETURNS TABLE(id uuid, member_id uuid, product_id uuid, start timestamp with time zone, stop timestamp with time zone, recurrence_id text, recurrence_rule text)
    LANGUAGE plpgsql
    AS $$
begin
  return query
  select 
    m.id,
    p.member_id,
    m.product_id,
    m.start,
    m.stop,
    m.recurrence_id,
    m.recurrence_rule
  from public.meetings m
  join public.products p on m.product_id = p.id;
end;
$$;


--
-- Name: get_register(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_register() RETURNS TABLE(member public.register_member, products public.register_product[])
    LANGUAGE sql SECURITY DEFINER
    AS $$
  with products_list as (
    select 
      p.id,
      p.member_id,
      p.summary,
      p.length,
      p.start,
      p.stop
    from public.products p
    left join sessions s on s.product_id = p.id
    group by p.id, p.member_id, p.summary, p.length, p.start, p.stop
  )
  
  select 
    (
      m.id,
      m.name,
      m.first_name,
      m.last_name,
      m.birth,
      m.color,
      a.email,
      a.phone
    )::register_member as member,
    case 
      when count(p.id) = 0 then null 
      else array_agg(
        (
          p.id,
          p.member_id,
          p.summary,
          p.length,
          p.start,
          p.stop
        )::register_product
      )
    end as products
  from members m
  left join users u on u.member_id = m.id
  left join auth.users a on a.id = u.auth_id
  left join products_list p on p.member_id = m.id
  group by 
    m.id, m.name, m.first_name, m.last_name, m.birth, m.color, a.email, a.phone
  order by m.name;
$$;


--
-- Name: get_sessions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_sessions() RETURNS TABLE(id uuid, member_id uuid, product_id uuid, start timestamp with time zone, stop timestamp with time zone, presence public.presence)
    LANGUAGE plpgsql
    AS $$
begin
  return query
  select 
    s.id,
    p.member_id,
    s.product_id,
    s.start,
    s.stop,
    s.presence
  from public.sessions s
  join public.products p on s.product_id = p.id;
end;
$$;


--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select exists (
    select 1
    from public.logins
    where auth_id = (select auth.uid())
      and auth_role = 'admin'
  );
$$;


--
-- Name: limited_access_signup_hook(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.limited_access_signup_hook(event jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE
    AS $$
declare
  v_email text;
  v_allowed boolean;
begin
  v_email := lower(trim(event->'user'->>'email'));
  if v_email is null or v_email = '' then
    return jsonb_build_object('error', jsonb_build_object(
      'http_code', 403,
      'message', 'No available email adress from provider.'));
  end if;

  select exists(
    select 1 from auth.users 
    where lower(email) = v_email 
      and delete_at is null 
      and banned_until is null
  ) into v_allowed;
  if not v_allowed then
    return jsonb_build_object('error', jsonb_build_object(
      'http_code', 403,
      'message', 'This address is not enabled.'));
  end if;

  return '{}'::jsonb;   -- oggetto vuoto = via libera
end;
$$;


--
-- Name: rls_auto_enable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rls_auto_enable() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


--
-- Name: set_meeting(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_meeting(p_meeting_id uuid, p_meeting jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  update public.meetings
  set
    start = (p_meeting->>'start')::timestamptz,
    stop = (p_meeting->>'stop')::timestamptz,
    recurrence_id = case 
      when p_meeting ? 'recurrence_id' 
      then (p_meeting->>'recurrence_id')::text 
      else recurrence_id 
    end,
    recurrence_rule = case 
      when p_meeting ? 'recurrence_rule' 
      then (p_meeting->>'recurrence_rule')::text 
      else recurrence_rule 
    end
  where id = p_meeting_id;
  
  -- if not found then
  --   raise notice 'Meeting with ID % not found.', p_meeting_id;
  -- end if;
end;
$$;


--
-- Name: set_member(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_member(p_member_id uuid, p_member jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  update public.members
  set
    name = (p_member->>'name')::text,
    first_name = (p_member->>'first_name')::text,
    last_name = (p_member->>'last_name')::text,
    birth = (p_member->>'birth')::date,
    color = (p_member->>'color')::text
  where id = p_member_id;
end;
$$;


--
-- Name: set_product(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_product(p_product_id uuid, p_product jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  update public.products
  set
    summary = (p_product->>'summary')::text,
    length = (p_product->>'length')::int4,
    start = (p_product->>'start')::date,
    stop = (p_product->>'stop')::date
  where id = p_product_id;
end;
$$;


--
-- Name: set_session(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_session(p_session_id uuid, p_session jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  update public.sessions
  set
    start = (p_session->>'start')::timestamptz,
    stop = (p_session->>'stop')::timestamptz,
    presence = (p_session->>'presence')::boolean
  where id = p_session_id;
  
  if not found then
    raise exception 'Session with ID % not found.', p_session_id;
  end if;
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gcal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcal (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    gcal_type public.sync_type,
    gcal_event_id text,
    gcal_synced_at timestamp with time zone,
    gcal_sync_status public.sync_status,
    gcal_sync_error text
);


--
-- Name: logins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logins (
    auth_id uuid NOT NULL,
    auth_role public.role
);


--
-- Name: meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meetings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    product_id uuid NOT NULL,
    start timestamp with time zone NOT NULL,
    stop timestamp with time zone NOT NULL,
    recurrence_id text,
    recurrence_rule text
);


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    birth date NOT NULL,
    color text NOT NULL
);


--
-- Name: presences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    product_id uuid NOT NULL,
    start timestamp with time zone NOT NULL,
    stop timestamp with time zone NOT NULL,
    presence boolean NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    member_id uuid NOT NULL,
    summary text DEFAULT ''::text NOT NULL,
    length integer NOT NULL,
    start date NOT NULL,
    stop date NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    product_id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    auth_id uuid,
    member_id uuid NOT NULL
);


--
-- Name: gcal gcal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcal
    ADD CONSTRAINT gcal_pkey PRIMARY KEY (id);


--
-- Name: logins logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logins
    ADD CONSTRAINT logins_pkey PRIMARY KEY (auth_id);


--
-- Name: meetings meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: presences sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey1 PRIMARY KEY (id);


--
-- Name: users users_auth_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_auth_id_key UNIQUE (auth_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (member_id);


--
-- Name: meetings_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX meetings_product_id_idx ON public.meetings USING btree (product_id);


--
-- Name: presences_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presences_product_id_idx ON public.presences USING btree (product_id);


--
-- Name: products_member_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_member_id_idx ON public.products USING btree (member_id);


--
-- Name: sessions_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_product_id_idx ON public.sessions USING btree (product_id);


--
-- Name: meetings gcal_meetings_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_meetings_delete AFTER DELETE ON public.meetings FOR EACH ROW EXECUTE FUNCTION public.gcal_enqueue_delete();


--
-- Name: meetings gcal_meetings_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_meetings_insert AFTER INSERT ON public.meetings FOR EACH ROW EXECUTE FUNCTION public.gcal_enqueue_upsert('meeting');


--
-- Name: meetings gcal_meetings_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_meetings_update AFTER UPDATE ON public.meetings FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE FUNCTION public.gcal_enqueue_upsert('meeting');


--
-- Name: members gcal_member_renamed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_member_renamed AFTER UPDATE OF name ON public.members FOR EACH ROW WHEN ((old.name IS DISTINCT FROM new.name)) EXECUTE FUNCTION public.gcal_member_update();


--
-- Name: presences gcal_presences_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_presences_delete AFTER DELETE ON public.presences FOR EACH ROW EXECUTE FUNCTION public.gcal_enqueue_delete();


--
-- Name: presences gcal_presences_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_presences_insert AFTER INSERT ON public.presences FOR EACH ROW EXECUTE FUNCTION public.gcal_enqueue_upsert('session');


--
-- Name: presences gcal_presences_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_presences_update AFTER UPDATE ON public.presences FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE FUNCTION public.gcal_enqueue_upsert('session');


--
-- Name: gcal gcal_sync_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_sync_insert AFTER INSERT ON public.gcal REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.gcal_sync();


--
-- Name: gcal gcal_sync_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gcal_sync_update AFTER UPDATE ON public.gcal REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION public.gcal_sync();


--
-- Name: logins logins_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logins
    ADD CONSTRAINT logins_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: meetings meetings_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: presences presences_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presences
    ADD CONSTRAINT presences_id_fkey FOREIGN KEY (id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: products products_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_product_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_product_id_fkey1 FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: users users_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id);


--
-- Name: users users_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: meetings Enable all for admin users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all for admin users" ON public.meetings TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: members Enable all for admin users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all for admin users" ON public.members TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: products Enable all for admin users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all for admin users" ON public.products TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: sessions Enable all for admin users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all for admin users" ON public.sessions TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: users Enable all for admin users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all for admin users" ON public.users TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: presences Enable all to admin users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all to admin users" ON public.presences TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: logins Enable read access to supabase_auth_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable read access to supabase_auth_admin" ON public.logins FOR SELECT TO supabase_auth_admin USING (true);


--
-- Name: gcal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.gcal ENABLE ROW LEVEL SECURITY;

--
-- Name: logins; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.logins ENABLE ROW LEVEL SECURITY;

--
-- Name: meetings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.meetings ENABLE ROW LEVEL SECURITY;

--
-- Name: members; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;

--
-- Name: presences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.presences ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict zplaCOwKaHxMbMKFFS2zPMyJRn9FW5NZIf1MDDIGMZHiN8SqF3y772pCcpDMkYl

