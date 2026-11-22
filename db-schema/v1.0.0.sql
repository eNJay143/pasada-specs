-- Pasada v1.0.0 | Supabase PostgreSQL | install as the postgres project owner.
-- Run the whole file as one transaction. No customer accounts or stop coordinates are seeded.
BEGIN;
CREATE SCHEMA IF NOT EXISTS pasada_private;
REVOKE ALL ON SCHEMA pasada_private FROM PUBLIC, anon, authenticated, service_role;

DO $types$
BEGIN
  IF to_regtype('public.pasada_direction') IS NULL THEN
    CREATE TYPE public.pasada_direction AS ENUM ('to_ormoc', 'to_sogod');
  END IF;
  IF to_regtype('public.pasada_field') IS NULL THEN
    CREATE TYPE public.pasada_field AS ENUM ('activity', 'seats', 'queue');
  END IF;
  IF to_regtype('public.pasada_value') IS NULL THEN
    CREATE TYPE public.pasada_value AS ENUM
      ('approaching','boarding','departed','spacious','standing_room','full','light','moderate','heavy');
  END IF;
  IF to_regtype('public.pasada_reason') IS NULL THEN
    CREATE TYPE public.pasada_reason AS ENUM ('wrong_direction','inaccurate','suspected_abuse');
  END IF;
END
$types$;

-- All application relationships use uuid; id is an internal ordered index only.
CREATE TABLE IF NOT EXISTS public.pasada_puv_type (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (btrim(name) <> ''),
  created_by uuid, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(), archived_at timestamptz
);
CREATE TABLE IF NOT EXISTS public.pasada_route (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  puv_type_uuid uuid NOT NULL REFERENCES public.pasada_puv_type(uuid),
  name text NOT NULL CHECK (btrim(name) <> ''),
  pilot_enabled boolean NOT NULL DEFAULT false,
  created_by uuid, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(), archived_at timestamptz
);
CREATE INDEX IF NOT EXISTS pasada_route_type_idx ON public.pasada_route(puv_type_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS pasada_one_pilot_route_idx
  ON public.pasada_route(pilot_enabled) WHERE pilot_enabled AND archived_at IS NULL;
CREATE TABLE IF NOT EXISTS public.pasada_stop (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (btrim(name) <> ''),
  created_by uuid, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(), archived_at timestamptz
);
CREATE TABLE IF NOT EXISTS public.pasada_boarding (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  route_uuid uuid NOT NULL REFERENCES public.pasada_route(uuid),
  stop_uuid uuid NOT NULL REFERENCES public.pasada_stop(uuid),
  direction public.pasada_direction NOT NULL,
  -- Surveyed public boarding point. Device positions are never written here.
  latitude double precision NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude double precision NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  stop_order integer NOT NULL CHECK (stop_order >= 0),
  created_by uuid, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(), archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS pasada_live_boarding_idx
  ON public.pasada_boarding(route_uuid,stop_uuid,direction) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS pasada_boarding_stop_idx ON public.pasada_boarding(stop_uuid);
CREATE TABLE IF NOT EXISTS public.pasada_setting (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE CHECK (name IN ('radius_m','bus_minutes','queue_minutes','cooldown_seconds')),
  value integer NOT NULL CHECK (value > 0),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS public.pasada_pilot_tally (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  boarding_uuid uuid NOT NULL REFERENCES public.pasada_boarding(uuid),
  sample_day date NOT NULL,
  checks integer NOT NULL CHECK (checks >= 0),
  confirmed integer NOT NULL CHECK (confirmed BETWEEN 0 AND checks),
  helpful integer NOT NULL CHECK (helpful BETWEEN 0 AND confirmed),
  created_by uuid, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(), archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS pasada_live_tally_idx
  ON public.pasada_pilot_tally(boarding_uuid,sample_day) WHERE archived_at IS NULL;

-- Operator assigns A/B/C after Google sign-in. All other Google users are contributors.
CREATE TABLE IF NOT EXISTS pasada_private.staff (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  account_uuid uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  level text NOT NULL CHECK (level IN ('A','B','C'))
);
CREATE TABLE IF NOT EXISTS pasada_private.guideline_hit (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  account_uuid uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  moderator_uuid uuid NOT NULL,
  reason public.pasada_reason NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  restricted_until timestamptz, revoked_at timestamptz, revoked_by uuid,
  CHECK (restricted_until IS NULL OR restricted_until > created_at)
);
CREATE INDEX IF NOT EXISTS pasada_hit_active_idx
  ON pasada_private.guideline_hit(account_uuid,restricted_until) WHERE revoked_at IS NULL;

-- Unlogged data can be lost on crash/failover. A quiet feed is preferable to stale reports.
-- Logical backups must explicitly exclude this schema's unlogged data (see design §9).
CREATE UNLOGGED TABLE IF NOT EXISTS pasada_private.receipt (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE,
  account_uuid uuid NOT NULL,
  accepted_at timestamptz NOT NULL,
  next_allowed_at timestamptz NOT NULL,
  expires_at timestamptz NOT NULL
);
CREATE INDEX IF NOT EXISTS pasada_receipt_account_idx ON pasada_private.receipt(account_uuid,next_allowed_at);
CREATE UNLOGGED TABLE IF NOT EXISTS pasada_private.observation (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  account_uuid uuid NOT NULL,
  boarding_uuid uuid NOT NULL REFERENCES public.pasada_boarding(uuid),
  field public.pasada_field NOT NULL, value public.pasada_value NOT NULL,
  accepted_at timestamptz NOT NULL, expires_at timestamptz NOT NULL CHECK (expires_at > accepted_at),
  UNIQUE (account_uuid,boarding_uuid,field),
  CHECK ((field='activity' AND value IN ('approaching','boarding','departed')) OR
         (field='seats' AND value IN ('spacious','standing_room','full')) OR
         (field='queue' AND value IN ('light','moderate','heavy')))
);
CREATE INDEX IF NOT EXISTS pasada_observation_feed_idx
  ON pasada_private.observation(boarding_uuid,field,value,expires_at);
CREATE INDEX IF NOT EXISTS pasada_observation_expiry_idx ON pasada_private.observation(expires_at);
CREATE UNLOGGED TABLE IF NOT EXISTS pasada_private.flag (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  reporter_uuid uuid NOT NULL,
  boarding_uuid uuid NOT NULL,
  field public.pasada_field NOT NULL, reason public.pasada_reason NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), expires_at timestamptz NOT NULL,
  UNIQUE (reporter_uuid,boarding_uuid,field)
);
CREATE UNLOGGED TABLE IF NOT EXISTS pasada_private.flag_evidence (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  flag_uuid uuid NOT NULL REFERENCES pasada_private.flag(uuid) ON DELETE CASCADE,
  observation_uuid uuid NOT NULL REFERENCES pasada_private.observation(uuid) ON DELETE CASCADE,
  UNIQUE(flag_uuid,observation_uuid)
);
CREATE INDEX IF NOT EXISTS pasada_flag_observation_idx ON pasada_private.flag_evidence(observation_uuid);

-- A corrected boarding point must not inherit sightings validated at the old point.
CREATE OR REPLACE FUNCTION pasada_private.clear_boarding_evidence()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  DELETE FROM pasada_private.observation WHERE boarding_uuid=OLD.uuid;
  DELETE FROM pasada_private.flag WHERE boarding_uuid=OLD.uuid;
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS clear_boarding_evidence ON public.pasada_boarding;
CREATE TRIGGER clear_boarding_evidence AFTER UPDATE ON public.pasada_boarding
  FOR EACH ROW WHEN (OLD.latitude IS DISTINCT FROM NEW.latitude OR
                     OLD.longitude IS DISTINCT FROM NEW.longitude OR
                     OLD.archived_at IS DISTINCT FROM NEW.archived_at)
  EXECUTE FUNCTION pasada_private.clear_boarding_evidence();

INSERT INTO public.pasada_puv_type(uuid,name)
SELECT 'f5713000-0000-4000-8000-000000000001','Metro Bus'
WHERE NOT EXISTS (SELECT FROM public.pasada_puv_type WHERE uuid='f5713000-0000-4000-8000-000000000001')
ON CONFLICT (uuid) DO NOTHING;
INSERT INTO public.pasada_route(uuid,puv_type_uuid,name,pilot_enabled)
SELECT 'f5713000-0000-4000-8000-000000000002','f5713000-0000-4000-8000-000000000001','Sogod–Ormoc',true
WHERE NOT EXISTS (SELECT FROM public.pasada_route WHERE uuid='f5713000-0000-4000-8000-000000000002')
ON CONFLICT (uuid) DO NOTHING;
INSERT INTO public.pasada_setting(name,value)
SELECT s.name,s.value FROM (VALUES
  ('radius_m',150),('bus_minutes',15),('queue_minutes',20),('cooldown_seconds',120)
) AS s(name,value)
WHERE NOT EXISTS (SELECT FROM public.pasada_setting existing WHERE existing.name=s.name)
ON CONFLICT (name) DO NOTHING;

CREATE OR REPLACE FUNCTION pasada_private.member_uuid()
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT u.id FROM auth.users u
  WHERE u.id = auth.uid() AND u.raw_app_meta_data->>'provider' = 'google'
$$;
CREATE OR REPLACE FUNCTION pasada_private.staff_access(allowed text[])
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT FROM pasada_private.staff
                 WHERE account_uuid = pasada_private.member_uuid() AND level = ANY(allowed))
$$;
CREATE OR REPLACE FUNCTION pasada_private.stamp_directory()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_by := auth.uid();
    NEW.created_at := clock_timestamp();
  END IF;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;

-- Reset Supabase's default grants on these relations before allowing named columns.
-- Directory edits are online. Clients refresh their complete, small public directory on reconnect.
DO $access$
DECLARE
  item record;
BEGIN
  FOR item IN SELECT * FROM (VALUES
    ('pasada_puv_type','name','name,archived_at'),
    ('pasada_route','puv_type_uuid,name','name,archived_at'),
    ('pasada_stop','name','name,archived_at'),
    ('pasada_boarding','route_uuid,stop_uuid,direction,latitude,longitude,stop_order',
                      'latitude,longitude,stop_order,archived_at'),
    ('pasada_pilot_tally','boarding_uuid,sample_day,checks,confirmed,helpful',
                         'checks,confirmed,helpful,archived_at')
  ) AS t(tbl,insert_cols,update_cols) LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',item.tbl);
    EXECUTE format('REVOKE ALL ON public.%I FROM PUBLIC, anon, authenticated, service_role',item.tbl);
    EXECUTE format('DROP POLICY IF EXISTS staff_config ON public.%I',item.tbl);
    EXECUTE format('CREATE POLICY staff_config ON public.%I TO authenticated
                    USING (pasada_private.staff_access(ARRAY[''A'',''B'']))
                    WITH CHECK (pasada_private.staff_access(ARRAY[''A'',''B'']))',item.tbl);
    EXECUTE format('GRANT SELECT (uuid,%s,created_at,updated_at,archived_at),
                    INSERT (uuid,%s), UPDATE (%s) ON public.%I TO authenticated',
                   item.insert_cols,item.insert_cols,item.update_cols,item.tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS stamp_directory ON public.%I',item.tbl);
    EXECUTE format('CREATE TRIGGER stamp_directory BEFORE INSERT OR UPDATE ON public.%I
                    FOR EACH ROW EXECUTE FUNCTION pasada_private.stamp_directory()',item.tbl);
  END LOOP;
END $access$;
GRANT SELECT (pilot_enabled) ON public.pasada_route TO authenticated;
-- Supabase may grant sequence access by default. Identity generation on INSERT
-- does not require a caller to inspect or manipulate the underlying sequence.
DO $sequences$
DECLARE tbl text;
BEGIN
  FOREACH tbl IN ARRAY ARRAY['pasada_puv_type','pasada_route','pasada_stop','pasada_boarding',
                              'pasada_setting','pasada_pilot_tally'] LOOP
    EXECUTE format('REVOKE ALL ON SEQUENCE %s FROM PUBLIC,anon,authenticated,service_role',
                   pg_get_serial_sequence('public.' || tbl,'id')::regclass);
  END LOOP;
END $sequences$;
ALTER TABLE public.pasada_setting ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.pasada_setting FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT (uuid,name,value,updated_at), UPDATE (value) ON public.pasada_setting TO authenticated;
DROP POLICY IF EXISTS staff_config ON public.pasada_setting;
CREATE POLICY staff_config ON public.pasada_setting TO authenticated
  USING (pasada_private.staff_access(ARRAY['A','B'])) WITH CHECK (pasada_private.staff_access(ARRAY['A','B']));
CREATE OR REPLACE FUNCTION pasada_private.stamp_setting()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN NEW.updated_at := clock_timestamp(); RETURN NEW; END $$;
DROP TRIGGER IF EXISTS stamp_setting ON public.pasada_setting;
CREATE TRIGGER stamp_setting BEFORE UPDATE ON public.pasada_setting
  FOR EACH ROW EXECUTE FUNCTION pasada_private.stamp_setting();

CREATE OR REPLACE FUNCTION public.pasada_directory()
RETURNS TABLE(puv_type_uuid uuid, puv_type text, route_uuid uuid, route_name text,
              stop_uuid uuid, stop_name text, boarding_uuid uuid, direction public.pasada_direction,
              latitude double precision, longitude double precision, stop_order integer, boarding_updated_at timestamptz)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT t.uuid,t.name,r.uuid,r.name,s.uuid,s.name,b.uuid,b.direction,b.latitude,b.longitude,b.stop_order,b.updated_at
  FROM public.pasada_boarding b
  JOIN public.pasada_route r ON r.uuid=b.route_uuid AND r.archived_at IS NULL AND r.pilot_enabled
  JOIN public.pasada_puv_type t ON t.uuid=r.puv_type_uuid AND t.archived_at IS NULL
  JOIN public.pasada_stop s ON s.uuid=b.stop_uuid AND s.archived_at IS NULL
  WHERE b.archived_at IS NULL
  ORDER BY r.name,b.direction,b.stop_order,s.name,b.uuid
$$;

-- One private row per account/boarding/field makes count(*) a distinct-account count.
CREATE OR REPLACE FUNCTION pasada_private.qualified(p_boarding uuid DEFAULT NULL)
RETURNS TABLE(boarding_uuid uuid, field public.pasada_field, value public.pasada_value, latest timestamptz)
LANGUAGE sql STABLE SET search_path = '' AS $$
  SELECT o.boarding_uuid,o.field,o.value,max(o.accepted_at)
  FROM pasada_private.observation o
  WHERE (p_boarding IS NULL OR o.boarding_uuid=p_boarding) AND o.expires_at > statement_timestamp()
  GROUP BY o.boarding_uuid,o.field,o.value HAVING count(*) >= 2
$$;
CREATE OR REPLACE FUNCTION public.pasada_feed(p_boarding uuid DEFAULT NULL)
RETURNS TABLE(boarding_uuid uuid, field public.pasada_field, status text,
              value public.pasada_value, latest_support_at timestamptz)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT d.boarding_uuid,f.field,
         CASE count(q.value) WHEN 0 THEN 'no_recent_confirmed_report'
              WHEN 1 THEN 'community_confirmed' ELSE 'reports_disagree' END,
         CASE WHEN count(q.value)=1 THEN min(q.value) END, max(q.latest)
  FROM public.pasada_directory() d CROSS JOIN unnest(enum_range(NULL::public.pasada_field)) f(field)
  LEFT JOIN pasada_private.qualified(p_boarding) q ON q.boarding_uuid=d.boarding_uuid AND q.field=f.field
  WHERE p_boarding IS NULL OR d.boarding_uuid=p_boarding
  GROUP BY d.boarding_uuid,f.field
$$;

-- Only pasada-api may call this RPC with its service credential. It verifies the Google
-- session, takes a fresh foreground fix, computes an upper bound (distance + accuracy)
-- against the selected boarding point, then discards the fix. None of these are client attestations.
CREATE OR REPLACE FUNCTION public.pasada_submit(
  p_account_uuid uuid, p_request_uuid uuid, p_boarding uuid, p_boarding_updated_at timestamptz,
  p_checked_at timestamptz, p_distance_bound_m double precision, p_field public.pasada_field,
  p_value public.pasada_value, p_seats public.pasada_value DEFAULT NULL, p_confirm boolean DEFAULT false
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  ts timestamptz;
  deadline timestamptz;
  cooldown interval;
  radius integer;
  minutes integer;
BEGIN
  IF p_request_uuid IS NULL OR NOT EXISTS (SELECT FROM auth.users
      WHERE id=p_account_uuid AND raw_app_meta_data->>'provider'='google') THEN
    RAISE EXCEPTION 'Verified Google account and request UUID required' USING ERRCODE='42501';
  END IF;
  -- Serialize all submissions from an account across devices, stops and fields.
  PERFORM pg_advisory_xact_lock(hashtextextended(p_account_uuid::text, 0));
  ts := clock_timestamp();
  IF EXISTS (SELECT FROM pasada_private.receipt WHERE uuid=p_request_uuid AND account_uuid=p_account_uuid) THEN
    RETURN;
  END IF;
  IF EXISTS (SELECT FROM pasada_private.guideline_hit WHERE account_uuid=p_account_uuid
             AND revoked_at IS NULL AND restricted_until>ts) THEN
    RAISE EXCEPTION 'Posting restricted' USING ERRCODE='42501';
  END IF;
  IF EXISTS (SELECT FROM pasada_private.receipt WHERE account_uuid=p_account_uuid AND next_allowed_at>ts) THEN
    RAISE EXCEPTION 'Submission cooldown active';
  END IF;
  SELECT max(value) FILTER (WHERE name='radius_m'),
         max(value) FILTER (WHERE name=CASE WHEN p_field='queue' THEN 'queue_minutes' ELSE 'bus_minutes' END),
         make_interval(secs=>max(value) FILTER (WHERE name='cooldown_seconds'))
  INTO radius,minutes,cooldown FROM public.pasada_setting;
  IF radius IS NULL OR minutes IS NULL OR cooldown IS NULL THEN RAISE EXCEPTION 'Pilot settings incomplete'; END IF;
  IF p_checked_at IS NULL OR p_checked_at NOT BETWEEN ts-interval '30 seconds' AND ts
     OR p_distance_bound_m IS NULL OR p_distance_bound_m NOT BETWEEN 0 AND radius THEN
    RAISE EXCEPTION 'Fresh location check at the selected active boarding point required';
  END IF;
  -- Hold the revision through commit so a concurrent correction cannot attach this
  -- submission to a boarding point that the device never checked.
  PERFORM 1 FROM public.pasada_boarding b
    JOIN public.pasada_stop s ON s.uuid=b.stop_uuid AND s.archived_at IS NULL
    JOIN public.pasada_route r ON r.uuid=b.route_uuid AND r.archived_at IS NULL AND r.pilot_enabled
    JOIN public.pasada_puv_type t ON t.uuid=r.puv_type_uuid AND t.archived_at IS NULL
    WHERE b.uuid=p_boarding AND b.archived_at IS NULL AND b.updated_at=p_boarding_updated_at
    FOR SHARE OF b,s,r,t;
  IF NOT FOUND THEN RAISE EXCEPTION 'Boarding point changed or is unavailable'; END IF;
  IF p_field IS NULL OR p_value IS NULL OR p_confirm IS NULL OR
     (p_seats IS NOT NULL AND (p_field <> 'activity' OR p_confirm OR
       p_seats NOT IN ('spacious','standing_room','full'))) OR (p_field='seats' AND NOT p_confirm) THEN
    RAISE EXCEPTION 'Invalid submission fields';
  END IF;
  IF p_confirm AND NOT EXISTS (SELECT FROM public.pasada_feed(p_boarding) f
       WHERE f.field=p_field AND f.status='community_confirmed' AND f.value=p_value) THEN
    RAISE EXCEPTION 'Field value is no longer confirmed';
  END IF;
  deadline := ts + make_interval(mins=>minutes);
  INSERT INTO pasada_private.receipt(uuid,account_uuid,accepted_at,next_allowed_at,expires_at)
  VALUES(p_request_uuid,p_account_uuid,ts,ts+cooldown,greatest(deadline,ts+cooldown));
  -- Replace the previous vote and detach any flags on it; an expired replacement
  -- must never resurrect an older vote. An omitted seat estimate leaves that field alone.
  DELETE FROM pasada_private.observation WHERE account_uuid=p_account_uuid AND boarding_uuid=p_boarding
    AND (field=p_field OR (p_seats IS NOT NULL AND field='seats'));
  INSERT INTO pasada_private.observation(account_uuid,boarding_uuid,field,value,accepted_at,expires_at)
  VALUES(p_account_uuid,p_boarding,p_field,p_value,ts,deadline);
  IF p_seats IS NOT NULL THEN
    INSERT INTO pasada_private.observation(account_uuid,boarding_uuid,field,value,accepted_at,expires_at)
    VALUES(p_account_uuid,p_boarding,'seats',p_seats,ts,deadline);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.pasada_flag_field(p_boarding uuid,p_field public.pasada_field,p_reason public.pasada_reason)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  reporter uuid := pasada_private.member_uuid();
  targets uuid[];
  deadline timestamptz;
  flag_key uuid;
BEGIN
  IF reporter IS NULL THEN RAISE EXCEPTION 'Sign-in required' USING ERRCODE='42501'; END IF;
  IF NOT EXISTS (SELECT FROM public.pasada_directory() WHERE boarding_uuid=p_boarding) THEN
    RAISE EXCEPTION 'Unknown boarding point';
  END IF;
  -- Capture only the observations that supported the public field when flagged.
  -- New reports at the same stop must not become evidence for an older complaint.
  SELECT array_agg(e.uuid),max(e.expires_at) INTO targets,deadline FROM (
    SELECT o.uuid,o.expires_at FROM pasada_private.observation o
    JOIN pasada_private.qualified(p_boarding) q USING(boarding_uuid,field,value)
    WHERE o.boarding_uuid=p_boarding AND o.field=p_field AND o.expires_at>statement_timestamp()
    ORDER BY o.uuid FOR SHARE OF o
  ) e;
  IF targets IS NULL THEN RAISE EXCEPTION 'Field has no published evidence'; END IF;
  INSERT INTO pasada_private.flag(reporter_uuid,boarding_uuid,field,reason,expires_at)
  VALUES(reporter,p_boarding,p_field,p_reason,deadline)
  ON CONFLICT(reporter_uuid,boarding_uuid,field) DO UPDATE
    SET reason=excluded.reason,expires_at=excluded.expires_at,created_at=statement_timestamp()
  RETURNING uuid INTO flag_key;
  DELETE FROM pasada_private.flag_evidence WHERE flag_uuid=flag_key;
  INSERT INTO pasada_private.flag_evidence(flag_uuid,observation_uuid) SELECT flag_key,unnest(targets);
END $$;

CREATE OR REPLACE FUNCTION pasada_private.require_moderator()
RETURNS void LANGUAGE plpgsql STABLE SET search_path = '' AS $$
BEGIN
  IF NOT pasada_private.staff_access(ARRAY['A','B','C']) THEN
    RAISE EXCEPTION 'Moderator access required' USING ERRCODE='42501';
  END IF;
END $$;
CREATE OR REPLACE FUNCTION public.pasada_review_queue()
RETURNS TABLE(flag_uuid uuid,reason public.pasada_reason,boarding_uuid uuid,field public.pasada_field,
              observation_uuid uuid,value public.pasada_value,accepted_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  PERFORM pasada_private.require_moderator();
  RETURN QUERY SELECT f.uuid,f.reason,f.boarding_uuid,f.field,o.uuid,o.value,o.accepted_at
    FROM pasada_private.flag f JOIN pasada_private.flag_evidence e ON e.flag_uuid=f.uuid
    JOIN pasada_private.observation o ON o.uuid=e.observation_uuid
    WHERE f.expires_at>statement_timestamp() AND o.expires_at>statement_timestamp()
    ORDER BY f.created_at,o.accepted_at;
END $$;

-- A dismissal closes a flag. Remove/hit acts on one specific live observation, so a
-- moderator cannot sanction every independent witness by flagging a summary.
CREATE OR REPLACE FUNCTION public.pasada_review(
  p_flag uuid,p_action text,p_observation uuid DEFAULT NULL,p_restricted_until timestamptz DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  accused uuid;
  flag_reason public.pasada_reason;
  hit_key uuid;
BEGIN
  PERFORM pasada_private.require_moderator();
  IF p_action IS NULL OR p_action NOT IN ('dismiss','remove','hit') OR
     (p_action <> 'hit' AND p_restricted_until IS NOT NULL) THEN RAISE EXCEPTION 'Invalid review action'; END IF;
  IF p_action='dismiss' THEN
    DELETE FROM pasada_private.flag WHERE uuid=p_flag;
    RETURN NULL;
  END IF;
  SELECT o.account_uuid,f.reason INTO STRICT accused,flag_reason
  FROM pasada_private.flag f JOIN pasada_private.flag_evidence e ON e.flag_uuid=f.uuid
  JOIN pasada_private.observation o ON o.uuid=e.observation_uuid
  WHERE f.uuid=p_flag AND o.uuid=p_observation
    AND o.expires_at>clock_timestamp() AND f.expires_at>clock_timestamp() FOR UPDATE OF o;
  IF p_action='hit' THEN
    INSERT INTO pasada_private.guideline_hit(account_uuid,moderator_uuid,reason,restricted_until)
    VALUES(accused,pasada_private.member_uuid(),flag_reason,p_restricted_until) RETURNING uuid INTO hit_key;
  END IF;
  DELETE FROM pasada_private.observation WHERE uuid=p_observation;
  RETURN hit_key;
END $$;
CREATE OR REPLACE FUNCTION public.pasada_revoke_hit(p_hit uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  PERFORM pasada_private.require_moderator();
  UPDATE pasada_private.guideline_hit SET revoked_at=clock_timestamp(),revoked_by=pasada_private.member_uuid()
  WHERE uuid=p_hit AND revoked_at IS NULL;
END $$;
CREATE OR REPLACE FUNCTION public.pasada_hits()
RETURNS TABLE(hit_uuid uuid,reason public.pasada_reason,issued_at timestamptz,restricted_until timestamptz,revoked_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  PERFORM pasada_private.require_moderator();
  RETURN QUERY SELECT h.uuid,h.reason,h.created_at,h.restricted_until,h.revoked_at
    FROM pasada_private.guideline_hit h ORDER BY h.created_at DESC;
END $$;

CREATE OR REPLACE FUNCTION pasada_private.purge()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  DELETE FROM pasada_private.observation WHERE expires_at<=clock_timestamp();
  DELETE FROM pasada_private.flag f WHERE f.expires_at<=clock_timestamp()
    OR NOT EXISTS (SELECT FROM pasada_private.flag_evidence e WHERE e.flag_uuid=f.uuid);
  DELETE FROM pasada_private.receipt WHERE expires_at<=clock_timestamp();
END $$;

-- Keep raw evidence out of PostgREST/Realtime; do not add private tables to publications.
REVOKE ALL ON ALL TABLES IN SCHEMA pasada_private FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA pasada_private FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA pasada_private FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION pasada_private.staff_access(text[]) TO authenticated;
DO $rpc$
DECLARE fn regprocedure;
BEGIN
  FOR fn IN SELECT p.oid::regprocedure FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
     WHERE n.nspname='public' AND p.proname IN ('pasada_directory','pasada_feed','pasada_submit',
       'pasada_flag_field','pasada_review_queue','pasada_review','pasada_hits','pasada_revoke_hit') LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',fn);
  END LOOP;
END $rpc$;
GRANT EXECUTE ON FUNCTION public.pasada_directory(), public.pasada_feed(uuid) TO anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.pasada_submit(uuid,uuid,uuid,timestamptz,timestamptz,double precision,
  public.pasada_field,public.pasada_value,public.pasada_value,boolean) TO service_role;
GRANT EXECUTE ON FUNCTION public.pasada_flag_field(uuid,public.pasada_field,public.pasada_reason),
  public.pasada_review_queue(), public.pasada_review(uuid,text,uuid,timestamptz),
  public.pasada_hits(), public.pasada_revoke_hit(uuid) TO authenticated;

-- The named job is updated on reinstallation. Reads already enforce expiry if a run is delayed.
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('pasada-purge-transient','* * * * *','SELECT pasada_private.purge()');
COMMIT;
