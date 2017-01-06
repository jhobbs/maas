--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: config_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION config_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('config_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.config_create_notify() OWNER TO gavin;

--
-- Name: config_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION config_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('config_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.config_delete_notify() OWNER TO gavin;

--
-- Name: config_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION config_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('config_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.config_update_notify() OWNER TO gavin;

--
-- Name: device_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION device_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  pnode RECORD;
BEGIN
  IF NEW.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = NEW.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_create',CAST(NEW.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.device_create_notify() OWNER TO gavin;

--
-- Name: device_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION device_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  pnode RECORD;
BEGIN
  IF OLD.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = OLD.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_delete',CAST(OLD.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.device_delete_notify() OWNER TO gavin;

--
-- Name: device_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION device_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  pnode RECORD;
BEGIN
  IF NEW.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = NEW.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(NEW.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.device_update_notify() OWNER TO gavin;

--
-- Name: dhcpsnippet_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dhcpsnippet_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('dhcpsnippet_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dhcpsnippet_create_notify() OWNER TO gavin;

--
-- Name: dhcpsnippet_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dhcpsnippet_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('dhcpsnippet_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dhcpsnippet_delete_notify() OWNER TO gavin;

--
-- Name: dhcpsnippet_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dhcpsnippet_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('dhcpsnippet_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dhcpsnippet_update_notify() OWNER TO gavin;

--
-- Name: dnsdata_domain_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dnsdata_domain_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    dom RECORD;
BEGIN
  SELECT DISTINCT ON (domain_id) domain_id INTO dom
  FROM maasserver_dnsresource AS dnsresource
  WHERE dnsresource.id = OLD.dnsresource_id;
  PERFORM pg_notify('domain_update',CAST(dom.domain_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dnsdata_domain_delete_notify() OWNER TO gavin;

--
-- Name: dnsdata_domain_insert_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dnsdata_domain_insert_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    dom RECORD;
BEGIN
  SELECT DISTINCT ON (domain_id) domain_id INTO dom
  FROM maasserver_dnsresource AS dnsresource
  WHERE dnsresource.id = NEW.dnsresource_id;
  PERFORM pg_notify('domain_update',CAST(dom.domain_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dnsdata_domain_insert_notify() OWNER TO gavin;

--
-- Name: dnsdata_domain_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dnsdata_domain_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    dom RECORD;
BEGIN
  SELECT DISTINCT ON (domain_id) domain_id INTO dom
  FROM maasserver_dnsresource AS dnsresource
  WHERE dnsresource.id = OLD.dnsresource_id OR dnsresource.id = NEW.dnsresource_id;
  PERFORM pg_notify('domain_update',CAST(dom.domain_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dnsdata_domain_update_notify() OWNER TO gavin;

--
-- Name: dnsresource_domain_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dnsresource_domain_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    domain RECORD;
BEGIN
  PERFORM pg_notify('domain_update',CAST(OLD.domain_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dnsresource_domain_delete_notify() OWNER TO gavin;

--
-- Name: dnsresource_domain_insert_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dnsresource_domain_insert_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    domain RECORD;
BEGIN
  PERFORM pg_notify('domain_update',CAST(NEW.domain_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dnsresource_domain_insert_notify() OWNER TO gavin;

--
-- Name: dnsresource_domain_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION dnsresource_domain_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    domain RECORD;
BEGIN
  PERFORM pg_notify('domain_update',CAST(OLD.domain_id AS text));
  IF OLD.domain_id != NEW.domain_id THEN
    PERFORM pg_notify('domain_update',CAST(NEW.domain_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.dnsresource_domain_update_notify() OWNER TO gavin;

--
-- Name: domain_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION domain_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('domain_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.domain_create_notify() OWNER TO gavin;

--
-- Name: domain_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION domain_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('domain_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.domain_delete_notify() OWNER TO gavin;

--
-- Name: domain_node_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION domain_node_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  IF OLD.name != NEW.name THEN
    SELECT system_id, node_type, parent_id INTO node
    FROM maasserver_node
    WHERE maasserver_node.domain_id = NEW.id;

    IF node.system_id IS NOT NULL THEN
      IF node.node_type = 0 THEN
        PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
      ELSIF node.node_type IN (2, 3, 4) THEN
        PERFORM pg_notify(
          'controller_update',CAST(node.system_id AS text));
      ELSIF node.parent_id IS NOT NULL THEN
        SELECT system_id INTO pnode
        FROM maasserver_node
        WHERE id = node.parent_id;
        PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
      ELSE
        PERFORM pg_notify('device_update',CAST(node.system_id AS text));
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.domain_node_update_notify() OWNER TO gavin;

--
-- Name: domain_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION domain_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('domain_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.domain_update_notify() OWNER TO gavin;

--
-- Name: event_create_machine_device_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION event_create_machine_device_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.event_create_machine_device_notify() OWNER TO gavin;

--
-- Name: event_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION event_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('event_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.event_create_notify() OWNER TO gavin;

--
-- Name: fabric_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION fabric_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('fabric_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fabric_create_notify() OWNER TO gavin;

--
-- Name: fabric_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION fabric_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('fabric_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fabric_delete_notify() OWNER TO gavin;

--
-- Name: fabric_machine_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION fabric_machine_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    node RECORD;
    pnode RECORD;
BEGIN
  FOR node IN (
    SELECT DISTINCT ON (maasserver_node.id)
      system_id, node_type, parent_id
    FROM
      maasserver_node,
      maasserver_fabric,
      maasserver_interface,
      maasserver_vlan
    WHERE maasserver_fabric.id = NEW.id
    AND maasserver_vlan.fabric_id = maasserver_fabric.id
    AND maasserver_node.id = maasserver_interface.node_id
    AND maasserver_vlan.id = maasserver_interface.vlan_id)
  LOOP
    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fabric_machine_update_notify() OWNER TO gavin;

--
-- Name: fabric_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION fabric_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('fabric_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.fabric_update_notify() OWNER TO gavin;

--
-- Name: ipaddress_domain_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION ipaddress_domain_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  dom RECORD;
BEGIN
  FOR dom IN (
    SELECT DISTINCT ON (domain.id)
      domain.id
    FROM maasserver_staticipaddress AS staticipaddress
    LEFT JOIN (
      maasserver_interface_ip_addresses AS iia
      JOIN maasserver_interface AS interface ON
        iia.interface_id = interface.id
      JOIN maasserver_node AS node ON
        node.id = interface.node_id) ON
      iia.staticipaddress_id = staticipaddress.id
    LEFT JOIN (
      maasserver_dnsresource_ip_addresses AS dia
      JOIN maasserver_dnsresource AS dnsresource ON
        dia.dnsresource_id = dnsresource.id) ON
      dia.staticipaddress_id = staticipaddress.id
    JOIN maasserver_domain AS domain ON
      domain.id = node.domain_id OR domain.id = dnsresource.domain_id
    WHERE staticipaddress.id = OLD.id)
  LOOP
    PERFORM pg_notify('domain_update',CAST(dom.id AS text));
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ipaddress_domain_delete_notify() OWNER TO gavin;

--
-- Name: ipaddress_domain_insert_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION ipaddress_domain_insert_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  dom RECORD;
BEGIN
  FOR dom IN (
    SELECT DISTINCT ON (domain.id)
      domain.id
    FROM maasserver_staticipaddress AS staticipaddress
    LEFT JOIN (
      maasserver_interface_ip_addresses AS iia
      JOIN maasserver_interface AS interface ON
        iia.interface_id = interface.id
      JOIN maasserver_node AS node ON
        node.id = interface.node_id) ON
      iia.staticipaddress_id = staticipaddress.id
    LEFT JOIN (
      maasserver_dnsresource_ip_addresses AS dia
      JOIN maasserver_dnsresource AS dnsresource ON
        dia.dnsresource_id = dnsresource.id) ON
      dia.staticipaddress_id = staticipaddress.id
    JOIN maasserver_domain AS domain ON
      domain.id = node.domain_id OR domain.id = dnsresource.domain_id
    WHERE staticipaddress.id = NEW.id)
  LOOP
    PERFORM pg_notify('domain_update',CAST(dom.id AS text));
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ipaddress_domain_insert_notify() OWNER TO gavin;

--
-- Name: ipaddress_domain_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION ipaddress_domain_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  dom RECORD;
BEGIN
  IF ((OLD.ip IS NULL and NEW.ip IS NOT NULL) OR
        (OLD.ip IS NOT NULL and NEW.ip IS NULL) OR
        OLD.ip != NEW.ip) THEN
    FOR dom IN (
      SELECT DISTINCT ON (domain.id)
        domain.id
      FROM maasserver_staticipaddress AS staticipaddress
      LEFT JOIN (
        maasserver_interface_ip_addresses AS iia
        JOIN maasserver_interface AS interface ON
          iia.interface_id = interface.id
        JOIN maasserver_node AS node ON
          node.id = interface.node_id) ON
        iia.staticipaddress_id = staticipaddress.id
      LEFT JOIN (
        maasserver_dnsresource_ip_addresses AS dia
        JOIN maasserver_dnsresource AS dnsresource ON
          dia.dnsresource_id = dnsresource.id) ON
        dia.staticipaddress_id = staticipaddress.id
      JOIN maasserver_domain AS domain ON
        domain.id = node.domain_id OR domain.id = dnsresource.domain_id
      WHERE staticipaddress.id = OLD.id OR staticipaddress.id = NEW.id)
    LOOP
      PERFORM pg_notify('domain_update',CAST(dom.id AS text));
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ipaddress_domain_update_notify() OWNER TO gavin;

--
-- Name: ipaddress_machine_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION ipaddress_machine_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    node RECORD;
    pnode RECORD;
BEGIN
  FOR node IN (
    SELECT DISTINCT ON (maasserver_node.id)
      system_id, node_type, parent_id
    FROM
      maasserver_node,
      maasserver_interface,
      maasserver_interface_ip_addresses AS ip_link
    WHERE ip_link.staticipaddress_id = NEW.id
    AND ip_link.interface_id = maasserver_interface.id
    AND maasserver_node.id = maasserver_interface.node_id)
  LOOP
    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ipaddress_machine_update_notify() OWNER TO gavin;

--
-- Name: ipaddress_subnet_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION ipaddress_subnet_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.subnet_id != NEW.subnet_id THEN
    IF OLD.subnet_id IS NOT NULL THEN
      PERFORM pg_notify('subnet_update',CAST(OLD.subnet_id AS text));
    END IF;
  END IF;
  IF NEW.subnet_id IS NOT NULL THEN
    PERFORM pg_notify('subnet_update',CAST(NEW.subnet_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ipaddress_subnet_update_notify() OWNER TO gavin;

--
-- Name: iprange_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION iprange_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('iprange_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.iprange_create_notify() OWNER TO gavin;

--
-- Name: iprange_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION iprange_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('iprange_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.iprange_delete_notify() OWNER TO gavin;

--
-- Name: iprange_subnet_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION iprange_subnet_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.subnet_id IS NOT NULL THEN
    PERFORM pg_notify('subnet_update',CAST(OLD.subnet_id AS text));
  END IF;
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.iprange_subnet_delete_notify() OWNER TO gavin;

--
-- Name: iprange_subnet_insert_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION iprange_subnet_insert_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.subnet_id IS NOT NULL THEN
    PERFORM pg_notify('subnet_update',CAST(NEW.subnet_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.iprange_subnet_insert_notify() OWNER TO gavin;

--
-- Name: iprange_subnet_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION iprange_subnet_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.subnet_id != NEW.subnet_id THEN
    IF OLD.subnet_id IS NOT NULL THEN
      PERFORM pg_notify('subnet_update',CAST(OLD.subnet_id AS text));
    END IF;
  END IF;
  IF NEW.subnet_id IS NOT NULL THEN
    PERFORM pg_notify('subnet_update',CAST(NEW.subnet_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.iprange_subnet_update_notify() OWNER TO gavin;

--
-- Name: iprange_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION iprange_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('iprange_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.iprange_update_notify() OWNER TO gavin;

--
-- Name: machine_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION machine_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('machine_create',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.machine_create_notify() OWNER TO gavin;

--
-- Name: machine_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION machine_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('machine_delete',CAST(OLD.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.machine_delete_notify() OWNER TO gavin;

--
-- Name: machine_device_tag_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION machine_device_tag_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.machine_device_tag_link_notify() OWNER TO gavin;

--
-- Name: machine_device_tag_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION machine_device_tag_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = OLD.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.machine_device_tag_unlink_notify() OWNER TO gavin;

--
-- Name: machine_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION machine_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('machine_update',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.machine_update_notify() OWNER TO gavin;

--
-- Name: nd_blockdevice_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_blockdevice_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_blockdevice_link_notify() OWNER TO gavin;

--
-- Name: nd_blockdevice_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_blockdevice_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = OLD.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_blockdevice_unlink_notify() OWNER TO gavin;

--
-- Name: nd_blockdevice_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_blockdevice_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_blockdevice_update_notify() OWNER TO gavin;

--
-- Name: nd_cacheset_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_cacheset_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partition,
       maasserver_partitiontable,
       maasserver_filesystem
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id =
      maasserver_partition.partition_table_id
  AND maasserver_partition.id = maasserver_filesystem.partition_id
  AND maasserver_filesystem.cache_set_id = NEW.id;

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_cacheset_link_notify() OWNER TO gavin;

--
-- Name: nd_cacheset_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_cacheset_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partition,
       maasserver_partitiontable,
       maasserver_filesystem
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id =
      maasserver_partition.partition_table_id
  AND maasserver_partition.id = maasserver_filesystem.partition_id
  AND maasserver_filesystem.cache_set_id = OLD.id;

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_cacheset_unlink_notify() OWNER TO gavin;

--
-- Name: nd_cacheset_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_cacheset_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partition,
       maasserver_partitiontable,
       maasserver_filesystem
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id =
      maasserver_partition.partition_table_id
  AND maasserver_partition.id = maasserver_filesystem.partition_id
  AND maasserver_filesystem.cache_set_id = NEW.id;

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_cacheset_update_notify() OWNER TO gavin;

--
-- Name: nd_filesystem_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_filesystem_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  IF NEW.block_device_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node,
           maasserver_blockdevice
     WHERE maasserver_node.id = maasserver_blockdevice.node_id
       AND maasserver_blockdevice.id = NEW.block_device_id;
  ELSIF NEW.partition_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node,
           maasserver_blockdevice,
           maasserver_partition,
           maasserver_partitiontable
     WHERE maasserver_node.id = maasserver_blockdevice.node_id
       AND maasserver_blockdevice.id =
           maasserver_partitiontable.block_device_id
       AND maasserver_partitiontable.id =
           maasserver_partition.partition_table_id
       AND maasserver_partition.id = NEW.partition_id;
  ELSIF NEW.node_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node
     WHERE maasserver_node.id = NEW.node_id;
  END IF;

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update', CAST(node.system_id AS text));
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_filesystem_link_notify() OWNER TO gavin;

--
-- Name: nd_filesystem_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_filesystem_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  IF OLD.block_device_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node,
           maasserver_blockdevice
     WHERE maasserver_node.id = maasserver_blockdevice.node_id
       AND maasserver_blockdevice.id = OLD.block_device_id;
  ELSIF OLD.partition_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node,
           maasserver_blockdevice,
           maasserver_partition,
           maasserver_partitiontable
     WHERE maasserver_node.id = maasserver_blockdevice.node_id
       AND maasserver_blockdevice.id =
           maasserver_partitiontable.block_device_id
       AND maasserver_partitiontable.id =
           maasserver_partition.partition_table_id
       AND maasserver_partition.id = OLD.partition_id;
  ELSIF OLD.node_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node
     WHERE maasserver_node.id = OLD.node_id;
  END IF;

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update', CAST(node.system_id AS text));
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_filesystem_unlink_notify() OWNER TO gavin;

--
-- Name: nd_filesystem_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_filesystem_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  IF NEW.block_device_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node,
           maasserver_blockdevice
     WHERE maasserver_node.id = maasserver_blockdevice.node_id
       AND maasserver_blockdevice.id = NEW.block_device_id;
  ELSIF NEW.partition_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node,
           maasserver_blockdevice,
           maasserver_partition,
           maasserver_partitiontable
     WHERE maasserver_node.id = maasserver_blockdevice.node_id
       AND maasserver_blockdevice.id =
           maasserver_partitiontable.block_device_id
       AND maasserver_partitiontable.id =
           maasserver_partition.partition_table_id
       AND maasserver_partition.id = NEW.partition_id;
  ELSIF NEW.node_id IS NOT NULL
  THEN
    SELECT system_id, node_type INTO node
      FROM maasserver_node
     WHERE maasserver_node.id = NEW.node_id;
  END IF;

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update', CAST(node.system_id AS text));
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_filesystem_update_notify() OWNER TO gavin;

--
-- Name: nd_filesystemgroup_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_filesystemgroup_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partition,
       maasserver_partitiontable,
       maasserver_filesystem
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id =
      maasserver_partition.partition_table_id
  AND maasserver_partition.id = maasserver_filesystem.partition_id
  AND (maasserver_filesystem.filesystem_group_id = NEW.id
      OR maasserver_filesystem.cache_set_id = NEW.cache_set_id);

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_filesystemgroup_link_notify() OWNER TO gavin;

--
-- Name: nd_filesystemgroup_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_filesystemgroup_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partition,
       maasserver_partitiontable,
       maasserver_filesystem
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id =
      maasserver_partition.partition_table_id
  AND maasserver_partition.id = maasserver_filesystem.partition_id
  AND (maasserver_filesystem.filesystem_group_id = OLD.id
      OR maasserver_filesystem.cache_set_id = OLD.cache_set_id);

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_filesystemgroup_unlink_notify() OWNER TO gavin;

--
-- Name: nd_filesystemgroup_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_filesystemgroup_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partition,
       maasserver_partitiontable,
       maasserver_filesystem
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id =
      maasserver_partition.partition_table_id
  AND maasserver_partition.id = maasserver_filesystem.partition_id
  AND (maasserver_filesystem.filesystem_group_id = NEW.id
      OR maasserver_filesystem.cache_set_id = NEW.cache_set_id);

  IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_filesystemgroup_update_notify() OWNER TO gavin;

--
-- Name: nd_interface_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_interface_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_interface_link_notify() OWNER TO gavin;

--
-- Name: nd_interface_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_interface_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = OLD.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_interface_unlink_notify() OWNER TO gavin;

--
-- Name: nd_interface_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_interface_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  IF OLD.node_id != NEW.node_id THEN
    SELECT system_id, node_type, parent_id INTO node
    FROM maasserver_node
    WHERE id = OLD.node_id;

    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END IF;

  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_interface_update_notify() OWNER TO gavin;

--
-- Name: nd_noderesult_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_noderesult_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = NEW.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_noderesult_link_notify() OWNER TO gavin;

--
-- Name: nd_noderesult_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_noderesult_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node
  WHERE id = OLD.node_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(
      node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_noderesult_unlink_notify() OWNER TO gavin;

--
-- Name: nd_partition_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_partition_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partitiontable
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id = NEW.partition_table_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_partition_link_notify() OWNER TO gavin;

--
-- Name: nd_partition_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_partition_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partitiontable
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id = OLD.partition_table_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_partition_unlink_notify() OWNER TO gavin;

--
-- Name: nd_partition_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_partition_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node,
       maasserver_blockdevice,
       maasserver_partitiontable
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = maasserver_partitiontable.block_device_id
  AND maasserver_partitiontable.id = NEW.partition_table_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_partition_update_notify() OWNER TO gavin;

--
-- Name: nd_partitiontable_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_partitiontable_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node, maasserver_blockdevice
    WHERE maasserver_node.id = maasserver_blockdevice.node_id
    AND maasserver_blockdevice.id = NEW.block_device_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_partitiontable_link_notify() OWNER TO gavin;

--
-- Name: nd_partitiontable_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_partitiontable_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node, maasserver_blockdevice
    WHERE maasserver_node.id = maasserver_blockdevice.node_id
    AND maasserver_blockdevice.id = OLD.block_device_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_partitiontable_unlink_notify() OWNER TO gavin;

--
-- Name: nd_partitiontable_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_partitiontable_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node, maasserver_blockdevice
    WHERE maasserver_node.id = maasserver_blockdevice.node_id
    AND maasserver_blockdevice.id = NEW.block_device_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_partitiontable_update_notify() OWNER TO gavin;

--
-- Name: nd_physblockdevice_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_physblockdevice_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node, maasserver_blockdevice
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = NEW.blockdevice_ptr_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_physblockdevice_update_notify() OWNER TO gavin;

--
-- Name: nd_sipaddress_dns_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_sipaddress_dns_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  domain RECORD;
BEGIN
  SELECT maasserver_domain.id INTO domain
  FROM maasserver_node, maasserver_interface, maasserver_domain
  WHERE maasserver_node.id = maasserver_interface.node_id
  AND maasserver_domain.id = maasserver_node.domain_id
  AND maasserver_interface.id = NEW.interface_id;

  IF domain.id IS NOT NULL THEN
    PERFORM pg_notify('domain_update',CAST(domain.id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_sipaddress_dns_link_notify() OWNER TO gavin;

--
-- Name: nd_sipaddress_dns_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_sipaddress_dns_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  domain RECORD;
BEGIN
  SELECT maasserver_domain.id INTO domain
  FROM maasserver_node, maasserver_interface, maasserver_domain
  WHERE maasserver_node.id = maasserver_interface.node_id
  AND maasserver_domain.id = maasserver_node.domain_id
  AND maasserver_interface.id = OLD.interface_id;

  IF domain.id IS NOT NULL THEN
    PERFORM pg_notify('domain_update',CAST(domain.id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_sipaddress_dns_unlink_notify() OWNER TO gavin;

--
-- Name: nd_sipaddress_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_sipaddress_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node, maasserver_interface
  WHERE maasserver_node.id = maasserver_interface.node_id
  AND maasserver_interface.id = NEW.interface_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_sipaddress_link_notify() OWNER TO gavin;

--
-- Name: nd_sipaddress_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_sipaddress_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  SELECT system_id, node_type, parent_id INTO node
  FROM maasserver_node, maasserver_interface
  WHERE maasserver_node.id = maasserver_interface.node_id
  AND maasserver_interface.id = OLD.interface_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  ELSIF node.node_type IN (2, 3, 4) THEN
    PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
  ELSIF node.parent_id IS NOT NULL THEN
    SELECT system_id INTO pnode
    FROM maasserver_node
    WHERE id = node.parent_id;
    PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
  ELSE
    PERFORM pg_notify('device_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_sipaddress_unlink_notify() OWNER TO gavin;

--
-- Name: nd_virtblockdevice_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION nd_virtblockdevice_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
BEGIN
  SELECT system_id, node_type INTO node
  FROM maasserver_node, maasserver_blockdevice
  WHERE maasserver_node.id = maasserver_blockdevice.node_id
  AND maasserver_blockdevice.id = NEW.blockdevice_ptr_id;

  IF node.node_type = 0 THEN
    PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.nd_virtblockdevice_update_notify() OWNER TO gavin;

--
-- Name: neighbour_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION neighbour_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('neighbour_create',CAST(NEW.ip AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.neighbour_create_notify() OWNER TO gavin;

--
-- Name: neighbour_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION neighbour_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('neighbour_delete',CAST(OLD.ip AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.neighbour_delete_notify() OWNER TO gavin;

--
-- Name: neighbour_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION neighbour_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('neighbour_update',CAST(NEW.ip AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.neighbour_update_notify() OWNER TO gavin;

--
-- Name: node_type_change_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION node_type_change_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (OLD.node_type != NEW.node_type AND NOT (
      (
        OLD.node_type = 2 OR
        OLD.node_type = 3 OR
        OLD.node_type = 4
      ) AND (
        NEW.node_type = 2 OR
        NEW.node_type = 3 OR
        NEW.node_type = 4
      ))) THEN
    CASE OLD.node_type
      WHEN 0 THEN
        PERFORM pg_notify('machine_delete',CAST(
          OLD.system_id AS TEXT));
      WHEN 1 THEN
        PERFORM pg_notify('device_delete',CAST(
          OLD.system_id AS TEXT));
      WHEN 2 THEN
        PERFORM pg_notify('controller_delete',CAST(
          OLD.system_id AS TEXT));
      WHEN 3 THEN
        PERFORM pg_notify('controller_delete',CAST(
          OLD.system_id AS TEXT));
      WHEN 4 THEN
        PERFORM pg_notify('controller_delete',CAST(
          OLD.system_id AS TEXT));
    END CASE;
    CASE NEW.node_type
      WHEN 0 THEN
        PERFORM pg_notify('machine_create',CAST(
          NEW.system_id AS TEXT));
      WHEN 1 THEN
        PERFORM pg_notify('device_create',CAST(
          NEW.system_id AS TEXT));
      WHEN 2 THEN
        PERFORM pg_notify('controller_create',CAST(
          NEW.system_id AS TEXT));
      WHEN 3 THEN
        PERFORM pg_notify('controller_create',CAST(
          NEW.system_id AS TEXT));
      WHEN 4 THEN
        PERFORM pg_notify('controller_create',CAST(
          NEW.system_id AS TEXT));
    END CASE;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.node_type_change_notify() OWNER TO gavin;

--
-- Name: packagerepository_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION packagerepository_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('packagerepository_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.packagerepository_create_notify() OWNER TO gavin;

--
-- Name: packagerepository_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION packagerepository_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('packagerepository_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.packagerepository_delete_notify() OWNER TO gavin;

--
-- Name: packagerepository_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION packagerepository_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('packagerepository_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.packagerepository_update_notify() OWNER TO gavin;

--
-- Name: rack_controller_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION rack_controller_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_create',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.rack_controller_create_notify() OWNER TO gavin;

--
-- Name: rack_controller_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION rack_controller_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_delete',CAST(OLD.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.rack_controller_delete_notify() OWNER TO gavin;

--
-- Name: rack_controller_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION rack_controller_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_update',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.rack_controller_update_notify() OWNER TO gavin;

--
-- Name: region_and_rack_controller_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION region_and_rack_controller_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_create',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.region_and_rack_controller_create_notify() OWNER TO gavin;

--
-- Name: region_and_rack_controller_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION region_and_rack_controller_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_delete',CAST(OLD.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.region_and_rack_controller_delete_notify() OWNER TO gavin;

--
-- Name: region_and_rack_controller_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION region_and_rack_controller_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_update',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.region_and_rack_controller_update_notify() OWNER TO gavin;

--
-- Name: region_controller_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION region_controller_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_create',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.region_controller_create_notify() OWNER TO gavin;

--
-- Name: region_controller_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION region_controller_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_delete',CAST(OLD.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.region_controller_delete_notify() OWNER TO gavin;

--
-- Name: region_controller_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION region_controller_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('controller_update',CAST(NEW.system_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.region_controller_update_notify() OWNER TO gavin;

--
-- Name: rrset_sipaddress_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION rrset_sipaddress_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  domain RECORD;
BEGIN
  SELECT maasserver_domain.id INTO domain
  FROM maasserver_dnsresource, maasserver_domain
  WHERE maasserver_domain.id = maasserver_dnsresource.domain_id
  AND maasserver_dnsresource.id = NEW.dnsresource_id;

  IF domain.id IS NOT NULL THEN
    PERFORM pg_notify('domain_update',CAST(domain.id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.rrset_sipaddress_link_notify() OWNER TO gavin;

--
-- Name: rrset_sipaddress_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION rrset_sipaddress_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  domain RECORD;
BEGIN
  SELECT maasserver_domain.id INTO domain
  FROM maasserver_dnsresource, maasserver_domain
  WHERE maasserver_domain.id = maasserver_dnsresource.domain_id
  AND maasserver_dnsresource.id = OLD.dnsresource_id;

  IF domain.id IS NOT NULL THEN
    PERFORM pg_notify('domain_update',CAST(domain.id AS text));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.rrset_sipaddress_unlink_notify() OWNER TO gavin;

--
-- Name: service_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION service_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('service_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.service_create_notify() OWNER TO gavin;

--
-- Name: service_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION service_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('service_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.service_delete_notify() OWNER TO gavin;

--
-- Name: service_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION service_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('service_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.service_update_notify() OWNER TO gavin;

--
-- Name: space_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION space_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('space_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.space_create_notify() OWNER TO gavin;

--
-- Name: space_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION space_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('space_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.space_delete_notify() OWNER TO gavin;

--
-- Name: space_machine_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION space_machine_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    node RECORD;
    pnode RECORD;
BEGIN
  FOR node IN (
    SELECT DISTINCT ON (maasserver_node.id)
      system_id, node_type, parent_id
    FROM
      maasserver_node,
      maasserver_space,
      maasserver_subnet,
      maasserver_vlan,
      maasserver_interface,
      maasserver_interface_ip_addresses AS ip_link,
      maasserver_staticipaddress
    WHERE maasserver_space.id = NEW.id
    AND maasserver_subnet.vlan_id = maasserver_vlan.id
    AND maasserver_vlan.space_id IS NOT DISTINCT FROM maasserver_space.id
    AND maasserver_staticipaddress.subnet_id = maasserver_subnet.id
    AND ip_link.staticipaddress_id = maasserver_staticipaddress.id
    AND ip_link.interface_id = maasserver_interface.id
    AND maasserver_node.id = maasserver_interface.node_id)
  LOOP
    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.space_machine_update_notify() OWNER TO gavin;

--
-- Name: space_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION space_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('space_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.space_update_notify() OWNER TO gavin;

--
-- Name: sshkey_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sshkey_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('sshkey_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sshkey_create_notify() OWNER TO gavin;

--
-- Name: sshkey_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sshkey_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('sshkey_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sshkey_delete_notify() OWNER TO gavin;

--
-- Name: sshkey_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sshkey_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('sshkey_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sshkey_update_notify() OWNER TO gavin;

--
-- Name: staticroute_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION staticroute_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('staticroute_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.staticroute_create_notify() OWNER TO gavin;

--
-- Name: staticroute_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION staticroute_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('staticroute_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.staticroute_delete_notify() OWNER TO gavin;

--
-- Name: staticroute_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION staticroute_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('staticroute_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.staticroute_update_notify() OWNER TO gavin;

--
-- Name: subnet_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION subnet_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('subnet_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.subnet_create_notify() OWNER TO gavin;

--
-- Name: subnet_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION subnet_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('subnet_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.subnet_delete_notify() OWNER TO gavin;

--
-- Name: subnet_machine_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION subnet_machine_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    node RECORD;
    pnode RECORD;
BEGIN
  FOR node IN (
    SELECT DISTINCT ON (maasserver_node.id)
      system_id, node_type, parent_id
    FROM
      maasserver_node,
      maasserver_subnet,
      maasserver_interface,
      maasserver_interface_ip_addresses AS ip_link,
      maasserver_staticipaddress
    WHERE maasserver_subnet.id = NEW.id
    AND maasserver_staticipaddress.subnet_id = maasserver_subnet.id
    AND ip_link.staticipaddress_id = maasserver_staticipaddress.id
    AND ip_link.interface_id = maasserver_interface.id
    AND maasserver_node.id = maasserver_interface.node_id)
  LOOP
    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.subnet_machine_update_notify() OWNER TO gavin;

--
-- Name: subnet_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION subnet_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('subnet_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.subnet_update_notify() OWNER TO gavin;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: maasserver_regioncontrollerprocess; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_regioncontrollerprocess (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    pid integer NOT NULL,
    region_id integer NOT NULL
);


ALTER TABLE maasserver_regioncontrollerprocess OWNER TO gavin;

--
-- Name: sys_core_get_managing_count(maasserver_regioncontrollerprocess); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_get_managing_count(process maasserver_regioncontrollerprocess) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (SELECT count(*)
    FROM maasserver_node
    WHERE maasserver_node.managing_process_id = process.id);
END;
$$;


ALTER FUNCTION public.sys_core_get_managing_count(process maasserver_regioncontrollerprocess) OWNER TO gavin;

--
-- Name: maasserver_node; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_node (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    system_id character varying(41) NOT NULL,
    hostname character varying(255) NOT NULL,
    status integer NOT NULL,
    bios_boot_method character varying(31),
    osystem character varying(255) NOT NULL,
    distro_series character varying(255) NOT NULL,
    architecture character varying(31),
    min_hwe_kernel character varying(31),
    hwe_kernel character varying(31),
    agent_name character varying(255),
    error_description text NOT NULL,
    cpu_count integer NOT NULL,
    memory integer NOT NULL,
    swap_size bigint,
    instance_power_parameters text NOT NULL,
    power_state character varying(10) NOT NULL,
    power_state_updated timestamp with time zone,
    error character varying(255) NOT NULL,
    netboot boolean NOT NULL,
    license_key character varying(30),
    boot_cluster_ip inet,
    enable_ssh boolean NOT NULL,
    skip_networking boolean NOT NULL,
    skip_storage boolean NOT NULL,
    boot_interface_id integer,
    gateway_link_ipv4_id integer,
    gateway_link_ipv6_id integer,
    owner_id integer,
    parent_id integer,
    token_id integer,
    zone_id integer NOT NULL,
    boot_disk_id integer,
    node_type integer NOT NULL,
    domain_id integer,
    dns_process_id integer,
    bmc_id integer,
    address_ttl integer,
    status_expires timestamp with time zone,
    power_state_queried timestamp with time zone,
    url character varying(255) NOT NULL,
    managing_process_id integer,
    last_image_sync timestamp with time zone,
    previous_status integer NOT NULL,
    default_user character varying(32) NOT NULL,
    cpu_speed integer NOT NULL,
    dynamic boolean NOT NULL,
    CONSTRAINT maasserver_node_address_ttl_check CHECK ((address_ttl >= 0))
);


ALTER TABLE maasserver_node OWNER TO gavin;

--
-- Name: sys_core_get_num_conn(maasserver_node); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_get_num_conn(rack maasserver_node) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT count(*)
    FROM
      maasserver_regionrackrpcconnection AS connection
    WHERE connection.rack_controller_id = rack.id);
END;
$$;


ALTER FUNCTION public.sys_core_get_num_conn(rack maasserver_node) OWNER TO gavin;

--
-- Name: sys_core_get_num_processes(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_get_num_processes() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT count(*) FROM maasserver_regioncontrollerprocess);
END;
$$;


ALTER FUNCTION public.sys_core_get_num_processes() OWNER TO gavin;

--
-- Name: sys_core_pick_new_region(maasserver_node); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_pick_new_region(rack maasserver_node) RETURNS maasserver_regioncontrollerprocess
    LANGUAGE plpgsql
    AS $$
DECLARE
  selected_managing integer;
  number_managing integer;
  selected_process maasserver_regioncontrollerprocess;
  process maasserver_regioncontrollerprocess;
BEGIN
  -- Get best region controller that can manage this rack controller.
  -- This is identified by picking a region controller process that
  -- at least has a connection to the rack controller and managing the
  -- least number of rack controllers.
  FOR process IN (
    SELECT DISTINCT ON (maasserver_regioncontrollerprocess.id)
      maasserver_regioncontrollerprocess.*
    FROM
      maasserver_regioncontrollerprocess,
      maasserver_regioncontrollerprocessendpoint,
      maasserver_regionrackrpcconnection
    WHERE maasserver_regionrackrpcconnection.rack_controller_id = rack.id
      AND maasserver_regionrackrpcconnection.endpoint_id =
        maasserver_regioncontrollerprocessendpoint.id
      AND maasserver_regioncontrollerprocessendpoint.process_id =
        maasserver_regioncontrollerprocess.id)
  LOOP
    IF selected_process IS NULL THEN
      -- First time through the loop so set the default.
      selected_process = process;
      selected_managing = sys_core_get_managing_count(process);
    ELSE
      -- See if the current process is managing less then the currently
      -- selected process.
      number_managing = sys_core_get_managing_count(process);
      IF number_managing = 0 THEN
        -- This process is managing zero so its the best, so we exit the
        -- loop now to return the selected.
        selected_process = process;
        EXIT;
      ELSIF number_managing < selected_managing THEN
        -- Managing less than the currently selected; select this process
        -- instead.
        selected_process = process;
        selected_managing = number_managing;
      END IF;
    END IF;
  END LOOP;
  RETURN selected_process;
END;
$$;


ALTER FUNCTION public.sys_core_pick_new_region(rack maasserver_node) OWNER TO gavin;

--
-- Name: sys_core_rpc_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_rpc_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rack_controller maasserver_node;
  region_process maasserver_regioncontrollerprocess;
BEGIN
  -- Connection from region <-> rack, has been removed. If that region
  -- process was managing that rack controller then a new one needs to
  -- be selected.
  SELECT maasserver_node.* INTO rack_controller
  FROM maasserver_node
  WHERE maasserver_node.id = OLD.rack_controller_id;

  -- Get the region process from the endpoint.
  SELECT
    process.* INTO region_process
  FROM
    maasserver_regioncontrollerprocess AS process,
    maasserver_regioncontrollerprocessendpoint AS endpoint
  WHERE process.id = endpoint.process_id
    AND endpoint.id = OLD.endpoint_id;

  -- Only perform an action if processes equal.
  IF rack_controller.managing_process_id = region_process.id THEN
    -- Region process was managing this rack controller. Tell it to stop
    -- watching the rack controller.
    PERFORM pg_notify(
      CONCAT('sys_core_', region_process.id),
      CONCAT('unwatch_', CAST(rack_controller.id AS text)));

    -- Pick a new region process for this rack controller.
    region_process = sys_core_pick_new_region(rack_controller);

    -- Update the rack controller and inform the new process.
    UPDATE maasserver_node
    SET managing_process_id = region_process.id
    WHERE maasserver_node.id = rack_controller.id;
    IF region_process.id IS NOT NULL THEN
      PERFORM pg_notify(
        CONCAT('sys_core_', region_process.id),
        CONCAT('watch_', CAST(rack_controller.id AS text)));
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_core_rpc_delete() OWNER TO gavin;

--
-- Name: sys_core_rpc_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_rpc_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rack_controller maasserver_node;
  region_process maasserver_regioncontrollerprocess;
BEGIN
  -- New connection from region <-> rack, check that the rack controller
  -- has a managing region controller.
  SELECT maasserver_node.* INTO rack_controller
  FROM maasserver_node
  WHERE maasserver_node.id = NEW.rack_controller_id;

  IF rack_controller.managing_process_id IS NULL THEN
    -- No managing region process for this rack controller.
    PERFORM sys_core_set_new_region(rack_controller);
  ELSE
    -- Currently managed check that the managing process is not dead.
    SELECT maasserver_regioncontrollerprocess.* INTO region_process
    FROM maasserver_regioncontrollerprocess
    WHERE maasserver_regioncontrollerprocess.id =
      rack_controller.managing_process_id;
    IF EXTRACT(EPOCH FROM region_process.updated) -
      EXTRACT(EPOCH FROM now()) > 90 THEN
      -- Region controller process is dead. A new region process needs to
      -- be selected for this rack controller.
      UPDATE maasserver_node SET managing_process_id = NULL
      WHERE maasserver_node.id = NEW.rack_controller_id;
      NEW.rack_controller_id = NULL;
      PERFORM sys_core_set_new_region(rack_controller);
    ELSE
      -- Currently being managed but lets see if we can re-balance the
      -- managing processes better. We only do the re-balance once the
      -- rack controller is connected to more than half of the running
      -- processes.
      IF sys_core_get_num_conn(rack_controller) /
        sys_core_get_num_processes() > 0.5 THEN
        -- Pick a new region process for this rack controller. Only update
        -- and perform the notification if the selection is different.
        region_process = sys_core_pick_new_region(rack_controller);
        IF region_process.id != rack_controller.managing_process_id THEN
          -- Alter the old process that its no longer responsable for
          -- this rack controller.
          PERFORM pg_notify(
            CONCAT('sys_core_', rack_controller.managing_process_id),
            CONCAT('unwatch_', CAST(rack_controller.id AS text)));
          -- Update the rack controller and alert the region controller.
          UPDATE maasserver_node
          SET managing_process_id = region_process.id
          WHERE maasserver_node.id = rack_controller.id;
          PERFORM pg_notify(
            CONCAT('sys_core_', region_process.id),
            CONCAT('watch_', CAST(rack_controller.id AS text)));
        END IF;
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_core_rpc_insert() OWNER TO gavin;

--
-- Name: sys_core_set_new_region(maasserver_node); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_core_set_new_region(rack maasserver_node) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  region_process maasserver_regioncontrollerprocess;
BEGIN
  -- Pick the new region process to manage this rack controller.
  region_process = sys_core_pick_new_region(rack);

  -- Update the rack controller and alert the region controller.
  UPDATE maasserver_node SET managing_process_id = region_process.id
  WHERE maasserver_node.id = rack.id;
  PERFORM pg_notify(
    CONCAT('sys_core_', region_process.id),
    CONCAT('watch_', CAST(rack.id AS text)));
  RETURN;
END;
$$;


ALTER FUNCTION public.sys_core_set_new_region(rack maasserver_node) OWNER TO gavin;

--
-- Name: maasserver_vlan; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_vlan (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256),
    vid integer NOT NULL,
    mtu integer NOT NULL,
    fabric_id integer NOT NULL,
    dhcp_on boolean NOT NULL,
    primary_rack_id integer,
    secondary_rack_id integer,
    external_dhcp inet,
    description text NOT NULL,
    relay_vlan_id integer,
    space_id integer
);


ALTER TABLE maasserver_vlan OWNER TO gavin;

--
-- Name: sys_dhcp_alert(maasserver_vlan); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_alert(vlan maasserver_vlan) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify(CONCAT('sys_dhcp_', vlan.primary_rack_id), '');
  IF vlan.secondary_rack_id IS NOT NULL THEN
    PERFORM pg_notify(CONCAT('sys_dhcp_', vlan.secondary_rack_id), '');
  END IF;
  RETURN;
END;
$$;


ALTER FUNCTION public.sys_dhcp_alert(vlan maasserver_vlan) OWNER TO gavin;

--
-- Name: sys_dhcp_config_ntp_servers_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_config_ntp_servers_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.name IN ('ntp_servers', 'ntp_external_only') THEN
    PERFORM sys_dhcp_update_all_vlans();
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_config_ntp_servers_delete() OWNER TO gavin;

--
-- Name: sys_dhcp_config_ntp_servers_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_config_ntp_servers_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.name = 'ntp_servers' THEN
    PERFORM sys_dhcp_update_all_vlans();
  ELSIF NEW.name = 'ntp_external_only' THEN
    PERFORM sys_dhcp_update_all_vlans();
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_config_ntp_servers_insert() OWNER TO gavin;

--
-- Name: sys_dhcp_config_ntp_servers_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_config_ntp_servers_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.name IN ('ntp_servers', 'ntp_external_only')
  OR NEW.name IN ('ntp_servers', 'ntp_external_only') THEN
    IF OLD.value != NEW.value THEN
      PERFORM sys_dhcp_update_all_vlans();
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_config_ntp_servers_update() OWNER TO gavin;

--
-- Name: sys_dhcp_interface_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_interface_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled and the interface name or MAC
  -- address has changed.
  IF OLD.name != NEW.name OR OLD.mac_address != NEW.mac_address THEN
    FOR vlan IN (
      SELECT DISTINCT ON (maasserver_vlan.id)
        maasserver_vlan.*
      FROM
        maasserver_vlan,
        maasserver_subnet,
        maasserver_staticipaddress,
        maasserver_interface_ip_addresses AS ip_link
      WHERE maasserver_staticipaddress.subnet_id = maasserver_subnet.id
      AND ip_link.staticipaddress_id = maasserver_staticipaddress.id
      AND ip_link.interface_id = NEW.id
      AND maasserver_staticipaddress.alloc_type != 6
      AND maasserver_staticipaddress.ip IS NOT NULL
      AND host(maasserver_staticipaddress.ip) != ''
      AND maasserver_vlan.id = maasserver_subnet.vlan_id
      AND maasserver_vlan.dhcp_on)
    LOOP
      PERFORM sys_dhcp_alert(vlan);
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_interface_update() OWNER TO gavin;

--
-- Name: sys_dhcp_iprange_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_iprange_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled and was dynamic range.
  IF OLD.type = 'dynamic' THEN
    SELECT maasserver_vlan.* INTO vlan
    FROM maasserver_vlan, maasserver_subnet
    WHERE maasserver_subnet.id = OLD.subnet_id AND
      maasserver_subnet.vlan_id = maasserver_vlan.id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_iprange_delete() OWNER TO gavin;

--
-- Name: sys_dhcp_iprange_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_iprange_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled and a dynamic range.
  IF NEW.type = 'dynamic' THEN
    SELECT maasserver_vlan.* INTO vlan
    FROM maasserver_vlan, maasserver_subnet
    WHERE maasserver_subnet.id = NEW.subnet_id AND
      maasserver_subnet.vlan_id = maasserver_vlan.id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_iprange_insert() OWNER TO gavin;

--
-- Name: sys_dhcp_iprange_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_iprange_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled and was or is now a dynamic range.
  IF OLD.type = 'dynamic' OR NEW.type = 'dynamic' THEN
    SELECT maasserver_vlan.* INTO vlan
    FROM maasserver_vlan, maasserver_subnet
    WHERE maasserver_subnet.id = NEW.subnet_id AND
      maasserver_subnet.vlan_id = maasserver_vlan.id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_iprange_update() OWNER TO gavin;

--
-- Name: sys_dhcp_node_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_node_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if on every interface on the node that is managed when
  -- the node hostname is changed.
  IF OLD.hostname != NEW.hostname THEN
    FOR vlan IN (
      SELECT DISTINCT ON (maasserver_vlan.id)
        maasserver_vlan.*
      FROM
        maasserver_vlan,
        maasserver_staticipaddress,
        maasserver_subnet,
        maasserver_interface,
        maasserver_interface_ip_addresses AS ip_link
      WHERE maasserver_staticipaddress.subnet_id = maasserver_subnet.id
      AND ip_link.staticipaddress_id = maasserver_staticipaddress.id
      AND ip_link.interface_id = maasserver_interface.id
      AND maasserver_interface.node_id = NEW.id
      AND maasserver_staticipaddress.alloc_type != 6
      AND maasserver_staticipaddress.ip IS NOT NULL
      AND host(maasserver_staticipaddress.ip) != ''
      AND maasserver_vlan.id = maasserver_subnet.vlan_id
      AND maasserver_vlan.dhcp_on)
    LOOP
      PERFORM sys_dhcp_alert(vlan);
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_node_update() OWNER TO gavin;

--
-- Name: sys_dhcp_snippet_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_snippet_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.enabled THEN
    PERFORM sys_dhcp_snippet_update_value(OLD);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_snippet_delete() OWNER TO gavin;

--
-- Name: sys_dhcp_snippet_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_snippet_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.enabled THEN
    PERFORM sys_dhcp_snippet_update_value(NEW);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_snippet_insert() OWNER TO gavin;

--
-- Name: sys_dhcp_snippet_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_snippet_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.enabled = NEW.enabled AND NEW.enabled IS FALSE THEN
    -- If the DHCP snippet is disabled don't fire any alerts
    RETURN NEW;
  ELSIF ((OLD.value_id != NEW.value_id) OR
      (OLD.enabled != NEW.enabled) OR
      (OLD.description != NEW.description)) THEN
    PERFORM sys_dhcp_snippet_update_value(NEW);
  ELSIF ((OLD.subnet_id IS NULL AND NEW.subnet_id IS NOT NULL) OR
      (OLD.subnet_id IS NOT NULL AND NEW.subnet_id IS NULL) OR
      (OLD.subnet_id != NEW.subnet_id)) THEN
    IF NEW.subnet_id IS NOT NULL THEN
      PERFORM sys_dhcp_snippet_update_subnet(NEW.subnet_id);
    END IF;
    IF OLD.subnet_id IS NOT NULL THEN
      PERFORM sys_dhcp_snippet_update_subnet(OLD.subnet_id);
    END IF;
  ELSIF ((OLD.node_id IS NULL AND NEW.node_id IS NOT NULL) OR
      (OLD.node_id IS NOT NULL AND NEW.node_id IS NULL) OR
      (OLD.node_id != NEW.node_id)) THEN
    IF NEW.node_id IS NOT NULL THEN
      PERFORM sys_dhcp_snippet_update_node(NEW.node_id);
    END IF;
    IF OLD.node_id IS NOT NULL THEN
      PERFORM sys_dhcp_snippet_update_node(OLD.node_id);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_snippet_update() OWNER TO gavin;

--
-- Name: sys_dhcp_snippet_update_node(integer); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_snippet_update_node(_node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  rack INTEGER;
BEGIN
  FOR rack IN (
    WITH racks AS (
      SELECT primary_rack_id, secondary_rack_id
      FROM maasserver_vlan, maasserver_interface
      WHERE maasserver_interface.node_id = _node_id
        AND maasserver_interface.vlan_id = maasserver_vlan.id
        AND maasserver_vlan.dhcp_on = true
    )
    SELECT primary_rack_id FROM racks
    WHERE primary_rack_id IS NOT NULL
    UNION
    SELECT secondary_rack_id FROM racks
    WHERE secondary_rack_id IS NOT NULL)
  LOOP
    PERFORM pg_notify(CONCAT('sys_dhcp_', rack), '');
  END LOOP;
  RETURN;
END;
$$;


ALTER FUNCTION public.sys_dhcp_snippet_update_node(_node_id integer) OWNER TO gavin;

--
-- Name: sys_dhcp_snippet_update_subnet(integer); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_snippet_update_subnet(_subnet_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  FOR vlan IN (
    SELECT
      maasserver_vlan.*
    FROM
      maasserver_vlan,
      maasserver_subnet
    WHERE maasserver_subnet.id = _subnet_id
      AND maasserver_vlan.id = maasserver_subnet.vlan_id
      AND maasserver_vlan.dhcp_on = true)
    LOOP
      PERFORM sys_dhcp_alert(vlan);
    END LOOP;
  RETURN;
END;
$$;


ALTER FUNCTION public.sys_dhcp_snippet_update_subnet(_subnet_id integer) OWNER TO gavin;

--
-- Name: maasserver_dhcpsnippet; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_dhcpsnippet (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    enabled boolean NOT NULL,
    node_id integer,
    subnet_id integer,
    value_id integer NOT NULL
);


ALTER TABLE maasserver_dhcpsnippet OWNER TO gavin;

--
-- Name: sys_dhcp_snippet_update_value(maasserver_dhcpsnippet); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_snippet_update_value(_dhcp_snippet maasserver_dhcpsnippet) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF _dhcp_snippet.subnet_id IS NOT NULL THEN
    PERFORM sys_dhcp_snippet_update_subnet(_dhcp_snippet.subnet_id);
  ELSIF _dhcp_snippet.node_id is NOT NULL THEN
    PERFORM sys_dhcp_snippet_update_node(_dhcp_snippet.node_id);
  ELSE
    -- This is a global snippet, everyone has to update. This should only
    -- be triggered when neither subnet_id or node_id are set. We verify
    -- that only subnet_id xor node_id are set in DHCPSnippet.clean()
    PERFORM sys_dhcp_update_all_vlans();
  END IF;
  RETURN;
END;
$$;


ALTER FUNCTION public.sys_dhcp_snippet_update_value(_dhcp_snippet maasserver_dhcpsnippet) OWNER TO gavin;

--
-- Name: sys_dhcp_staticipaddress_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_staticipaddress_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled and has an IP address.
  IF host(OLD.ip) != '' THEN
    SELECT maasserver_vlan.* INTO vlan
    FROM maasserver_vlan, maasserver_subnet
    WHERE maasserver_subnet.id = OLD.subnet_id AND
      maasserver_subnet.vlan_id = maasserver_vlan.id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_staticipaddress_delete() OWNER TO gavin;

--
-- Name: sys_dhcp_staticipaddress_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_staticipaddress_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled, IP is set and not DISCOVERED.
  IF NEW.alloc_type != 6 AND NEW.ip IS NOT NULL AND host(NEW.ip) != '' THEN
    SELECT maasserver_vlan.* INTO vlan
    FROM maasserver_vlan, maasserver_subnet
    WHERE maasserver_subnet.id = NEW.subnet_id AND
      maasserver_subnet.vlan_id = maasserver_vlan.id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_staticipaddress_insert() OWNER TO gavin;

--
-- Name: sys_dhcp_staticipaddress_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_staticipaddress_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  old_vlan maasserver_vlan;
  new_vlan maasserver_vlan;
BEGIN
  -- Ignore DISCOVERED IP addresses.
  IF NEW.alloc_type != 6 THEN
    IF OLD.subnet_id != NEW.subnet_id THEN
      -- Subnet has changed; update each VLAN if different.
      SELECT maasserver_vlan.* INTO old_vlan
      FROM maasserver_vlan, maasserver_subnet
      WHERE maasserver_subnet.id = OLD.subnet_id AND
        maasserver_subnet.vlan_id = maasserver_vlan.id;
      SELECT maasserver_vlan.* INTO new_vlan
      FROM maasserver_vlan, maasserver_subnet
      WHERE maasserver_subnet.id = NEW.subnet_id AND
        maasserver_subnet.vlan_id = maasserver_vlan.id;
      IF old_vlan.id != new_vlan.id THEN
        -- Different VLAN's; update each if DHCP enabled.
        IF old_vlan.dhcp_on THEN
          PERFORM sys_dhcp_alert(old_vlan);
        END IF;
        IF new_vlan.dhcp_on THEN
          PERFORM sys_dhcp_alert(new_vlan);
        END IF;
      ELSE
        -- Same VLAN so only need to update once.
        IF new_vlan.dhcp_on THEN
          PERFORM sys_dhcp_alert(new_vlan);
        END IF;
      END IF;
    ELSIF (OLD.ip IS NULL AND NEW.ip IS NOT NULL) OR
      (OLD.ip IS NOT NULL and NEW.ip IS NULL) OR
      (host(OLD.ip) != host(NEW.ip)) THEN
      -- Assigned IP address has changed.
      SELECT maasserver_vlan.* INTO new_vlan
      FROM maasserver_vlan, maasserver_subnet
      WHERE maasserver_subnet.id = NEW.subnet_id AND
        maasserver_subnet.vlan_id = maasserver_vlan.id;
      IF new_vlan.dhcp_on THEN
        PERFORM sys_dhcp_alert(new_vlan);
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_staticipaddress_update() OWNER TO gavin;

--
-- Name: sys_dhcp_subnet_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_subnet_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Update VLAN if DHCP is enabled.
  SELECT * INTO vlan
  FROM maasserver_vlan WHERE id = OLD.vlan_id;
  IF vlan.dhcp_on THEN
    PERFORM sys_dhcp_alert(vlan);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_subnet_delete() OWNER TO gavin;

--
-- Name: sys_dhcp_subnet_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_subnet_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  vlan maasserver_vlan;
BEGIN
  -- Subnet was moved to a new VLAN.
  IF OLD.vlan_id != NEW.vlan_id THEN
    -- Update old VLAN if DHCP is enabled.
    SELECT * INTO vlan
    FROM maasserver_vlan WHERE id = OLD.vlan_id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
    -- Update the new VLAN if DHCP is enabled.
    SELECT * INTO vlan
    FROM maasserver_vlan WHERE id = NEW.vlan_id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  -- Related fields of subnet where changed.
  ELSIF OLD.cidr != NEW.cidr OR
    (OLD.gateway_ip IS NULL AND NEW.gateway_ip IS NOT NULL) OR
    (OLD.gateway_ip IS NOT NULL AND NEW.gateway_ip IS NULL) OR
    host(OLD.gateway_ip) != host(NEW.gateway_ip) OR
    OLD.dns_servers != NEW.dns_servers THEN
    -- Network has changed update alert DHCP if enabled.
    SELECT * INTO vlan
    FROM maasserver_vlan WHERE id = NEW.vlan_id;
    IF vlan.dhcp_on THEN
      PERFORM sys_dhcp_alert(vlan);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_subnet_update() OWNER TO gavin;

--
-- Name: sys_dhcp_update_all_vlans(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_update_all_vlans() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  rack INTEGER;
BEGIN
  FOR rack IN (
    WITH racks AS (
      SELECT primary_rack_id, secondary_rack_id FROM maasserver_vlan
      WHERE maasserver_vlan.dhcp_on = true
    )
    SELECT primary_rack_id FROM racks
    WHERE primary_rack_id IS NOT NULL
    UNION
    SELECT secondary_rack_id FROM racks
    WHERE secondary_rack_id IS NOT NULL)
  LOOP
    PERFORM pg_notify(CONCAT('sys_dhcp_', rack), '');
  END LOOP;
  RETURN;
END;
$$;


ALTER FUNCTION public.sys_dhcp_update_all_vlans() OWNER TO gavin;

--
-- Name: sys_dhcp_vlan_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dhcp_vlan_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  relay_vlan maasserver_vlan;
BEGIN
  -- DHCP was turned off.
  IF OLD.dhcp_on AND NOT NEW.dhcp_on THEN
    PERFORM pg_notify(CONCAT('sys_dhcp_', OLD.primary_rack_id), '');
    IF OLD.secondary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(CONCAT('sys_dhcp_', OLD.secondary_rack_id), '');
    END IF;
  -- DHCP was turned on.
  ELSIF NOT OLD.dhcp_on AND NEW.dhcp_on THEN
    PERFORM pg_notify(CONCAT('sys_dhcp_', NEW.primary_rack_id), '');
    IF NEW.secondary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(CONCAT('sys_dhcp_', NEW.secondary_rack_id), '');
    END IF;
  -- DHCP state was not changed but the rack controllers might have been.
  ELSIF NEW.dhcp_on AND (
     OLD.primary_rack_id != NEW.primary_rack_id OR (
       OLD.secondary_rack_id IS NULL AND
       NEW.secondary_rack_id IS NOT NULL) OR (
       OLD.secondary_rack_id IS NOT NULL AND
       NEW.secondary_rack_id IS NULL) OR
     OLD.secondary_rack_id != NEW.secondary_rack_id) THEN
    -- Send the message to the old primary if no longer the primary.
    IF OLD.primary_rack_id != NEW.primary_rack_id THEN
      PERFORM pg_notify(CONCAT('sys_dhcp_', OLD.primary_rack_id), '');
    END IF;
    -- Always send the message to the primary as it has to be set.
    PERFORM pg_notify(CONCAT('sys_dhcp_', NEW.primary_rack_id), '');
    -- Send message to both old and new secondary rack controller if set.
    IF OLD.secondary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(CONCAT('sys_dhcp_', OLD.secondary_rack_id), '');
    END IF;
    IF NEW.secondary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(CONCAT('sys_dhcp_', NEW.secondary_rack_id), '');
    END IF;
  END IF;

  -- Relay VLAN was set when it was previously unset.
  IF OLD.relay_vlan_id IS NULL AND NEW.relay_vlan_id IS NOT NULL THEN
    SELECT maasserver_vlan.* INTO relay_vlan
    FROM maasserver_vlan
    WHERE maasserver_vlan.id = NEW.relay_vlan_id;
    IF relay_vlan.primary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(
        CONCAT('sys_dhcp_', relay_vlan.primary_rack_id), '');
      IF relay_vlan.secondary_rack_id IS NOT NULL THEN
        PERFORM pg_notify(
          CONCAT('sys_dhcp_', relay_vlan.secondary_rack_id), '');
      END IF;
    END IF;
  -- Relay VLAN was unset when it was previously set.
  ELSIF OLD.relay_vlan_id IS NOT NULL AND NEW.relay_vlan_id IS NULL THEN
    SELECT maasserver_vlan.* INTO relay_vlan
    FROM maasserver_vlan
    WHERE maasserver_vlan.id = OLD.relay_vlan_id;
    IF relay_vlan.primary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(
        CONCAT('sys_dhcp_', relay_vlan.primary_rack_id), '');
      IF relay_vlan.secondary_rack_id IS NOT NULL THEN
        PERFORM pg_notify(
          CONCAT('sys_dhcp_', relay_vlan.secondary_rack_id), '');
      END IF;
    END IF;
  -- Relay VLAN has changed on the VLAN.
  ELSIF OLD.relay_vlan_id != NEW.relay_vlan_id THEN
    -- Alert old VLAN if required.
    SELECT maasserver_vlan.* INTO relay_vlan
    FROM maasserver_vlan
    WHERE maasserver_vlan.id = OLD.relay_vlan_id;
    IF relay_vlan.primary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(
        CONCAT('sys_dhcp_', relay_vlan.primary_rack_id), '');
      IF relay_vlan.secondary_rack_id IS NOT NULL THEN
        PERFORM pg_notify(
          CONCAT('sys_dhcp_', relay_vlan.secondary_rack_id), '');
      END IF;
    END IF;
    -- Alert new VLAN if required.
    SELECT maasserver_vlan.* INTO relay_vlan
    FROM maasserver_vlan
    WHERE maasserver_vlan.id = NEW.relay_vlan_id;
    IF relay_vlan.primary_rack_id IS NOT NULL THEN
      PERFORM pg_notify(
        CONCAT('sys_dhcp_', relay_vlan.primary_rack_id), '');
      IF relay_vlan.secondary_rack_id IS NOT NULL THEN
        PERFORM pg_notify(
          CONCAT('sys_dhcp_', relay_vlan.secondary_rack_id), '');
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dhcp_vlan_update() OWNER TO gavin;

--
-- Name: sys_dns_config_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_config_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Only care about the
  IF (NEW.name = 'upstream_dns' OR
      NEW.name = 'dnssec_validation' OR
      NEW.name = 'default_dns_ttl' OR
      NEW.name = 'windows_kms_host')
  THEN
    INSERT INTO maasserver_dnspublication
      (serial, created, source)
    VALUES
      (nextval('maasserver_zone_serial_seq'), now(), substring(
        ('Configuration ' || NEW.name || ' set to ' ||
         COALESCE(NEW.value, 'NULL'))
        FOR 255));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_config_insert() OWNER TO gavin;

--
-- Name: sys_dns_config_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_config_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Only care about the upstream_dns, default_dns_ttl, and
  -- windows_kms_host.
  IF (OLD.value != NEW.value AND (
      NEW.name = 'upstream_dns' OR
      NEW.name = 'dnssec_validation' OR
      NEW.name = 'default_dns_ttl' OR
      NEW.name = 'windows_kms_host'))
  THEN
    INSERT INTO maasserver_dnspublication
      (serial, created, source)
    VALUES
      (nextval('maasserver_zone_serial_seq'), now(), substring(
        ('Configuration ' || NEW.name || ' changed from ' ||
         OLD.value || ' to ' || NEW.value)
        FOR 255));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_config_update() OWNER TO gavin;

--
-- Name: sys_dns_dnsdata_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsdata_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsdata_delete' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsdata_delete() OWNER TO gavin;

--
-- Name: sys_dns_dnsdata_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsdata_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsdata_insert' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsdata_insert() OWNER TO gavin;

--
-- Name: sys_dns_dnsdata_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsdata_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsdata_update' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsdata_update() OWNER TO gavin;

--
-- Name: sys_dns_dnsresource_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsresource_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsresource_delete' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsresource_delete() OWNER TO gavin;

--
-- Name: sys_dns_dnsresource_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsresource_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsresource_insert' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsresource_insert() OWNER TO gavin;

--
-- Name: sys_dns_dnsresource_ip_link(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsresource_ip_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsresource_ip_link' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsresource_ip_link() OWNER TO gavin;

--
-- Name: sys_dns_dnsresource_ip_unlink(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsresource_ip_unlink() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsresource_ip_unlink' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsresource_ip_unlink() OWNER TO gavin;

--
-- Name: sys_dns_dnsresource_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_dnsresource_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_dnsresource_update' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_dnsresource_update() OWNER TO gavin;

--
-- Name: sys_dns_domain_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_domain_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_domain_delete' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_domain_delete() OWNER TO gavin;

--
-- Name: sys_dns_domain_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_domain_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_domain_insert' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_domain_insert() OWNER TO gavin;

--
-- Name: sys_dns_domain_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_domain_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_domain_update' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_domain_update() OWNER TO gavin;

--
-- Name: sys_dns_interface_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_interface_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  changes text[];
BEGIN
  IF OLD.name != NEW.name THEN
    changes := changes || (
      'renamed from ' || OLD.name || ' to ' || NEW.name);
  END IF;
  IF OLD.node_id IS NULL AND NEW.node_id IS NOT NULL THEN
    changes := changes || 'node set'::text;
  ELSIF OLD.node_id IS NOT NULL AND NEW.node_id IS NULL THEN
    changes := changes || 'node unset'::text;
  ELSIF OLD.node_id != NEW.node_id THEN
    changes := changes || 'node changed'::text;
  END IF;
  IF array_length(changes, 1) != 0 THEN
    INSERT INTO maasserver_dnspublication
      (serial, created, source)
    VALUES
      (nextval('maasserver_zone_serial_seq'), now(),
       substring(
         ('Interface ' || NEW.name || ': ' ||
          array_to_string(changes, ', '))
         FOR 255));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_interface_update() OWNER TO gavin;

--
-- Name: sys_dns_nic_ip_link(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_nic_ip_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_nic_ip_link' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_nic_ip_link() OWNER TO gavin;

--
-- Name: sys_dns_nic_ip_unlink(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_nic_ip_unlink() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_nic_ip_unlink' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_nic_ip_unlink() OWNER TO gavin;

--
-- Name: sys_dns_node_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_node_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_node_delete' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_node_delete() OWNER TO gavin;

--
-- Name: sys_dns_node_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_node_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  changes text[];
BEGIN
  IF OLD.hostname != NEW.hostname THEN
    changes := changes || (
      'hostname changed from ' || OLD.hostname || ' to ' || NEW.hostname);
  END IF;
  IF OLD.domain_id != NEW.domain_id THEN
    changes := changes || 'domain changed'::text;
  END IF;
  IF array_length(changes, 1) != 0 THEN
    INSERT INTO maasserver_dnspublication
      (serial, created, source)
    VALUES
      (nextval('maasserver_zone_serial_seq'), now(),
       substring(
         ('Node ' || NEW.system_id || ': ' ||
          array_to_string(changes, ', '))
         FOR 255));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_node_update() OWNER TO gavin;

--
-- Name: sys_dns_publish(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_publish() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify('sys_dns', '');
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_publish() OWNER TO gavin;

--
-- Name: sys_dns_staticipaddress_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_staticipaddress_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_staticipaddress_update' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_staticipaddress_update() OWNER TO gavin;

--
-- Name: sys_dns_subnet_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_subnet_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_subnet_delete' FOR 255));
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_dns_subnet_delete() OWNER TO gavin;

--
-- Name: sys_dns_subnet_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_subnet_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maasserver_dnspublication
    (serial, created, source)
  VALUES
    (nextval('maasserver_zone_serial_seq'), now(),
     substring('Call to sys_dns_subnet_insert' FOR 255));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_subnet_insert() OWNER TO gavin;

--
-- Name: sys_dns_subnet_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_dns_subnet_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  changes text[];
BEGIN
  IF OLD.cidr != NEW.cidr THEN
    changes := changes || (
      'CIDR changed from ' || OLD.cidr || ' to ' || NEW.cidr);
  END IF;
  IF OLD.rdns_mode != NEW.rdns_mode THEN
    changes := changes || (
      'RDNS mode changed from ' || OLD.rdns_mode || ' to ' ||
      NEW.rdns_mode);
  END IF;
  IF array_length(changes, 1) != 0 THEN
    INSERT INTO maasserver_dnspublication
      (serial, created, source)
    VALUES
      (nextval('maasserver_zone_serial_seq'), now(),
       substring(
         ('Subnet ' || NEW.name || ': ' || array_to_string(changes, ', '))
         FOR 255));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_dns_subnet_update() OWNER TO gavin;

--
-- Name: sys_proxy_subnet_delete(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_proxy_subnet_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify('sys_proxy', '');
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.sys_proxy_subnet_delete() OWNER TO gavin;

--
-- Name: sys_proxy_subnet_insert(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_proxy_subnet_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify('sys_proxy', '');
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_proxy_subnet_insert() OWNER TO gavin;

--
-- Name: sys_proxy_subnet_update(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION sys_proxy_subnet_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.cidr != NEW.cidr OR OLD.allow_proxy != NEW.allow_proxy THEN
    PERFORM pg_notify('sys_proxy', '');
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sys_proxy_subnet_update() OWNER TO gavin;

--
-- Name: tag_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION tag_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('tag_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.tag_create_notify() OWNER TO gavin;

--
-- Name: tag_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION tag_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('tag_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.tag_delete_notify() OWNER TO gavin;

--
-- Name: tag_update_machine_device_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION tag_update_machine_device_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  node RECORD;
  pnode RECORD;
BEGIN
  FOR node IN (
    SELECT
      maasserver_node.system_id,
      maasserver_node.node_type,
      maasserver_node.parent_id
    FROM maasserver_node_tags, maasserver_node
    WHERE maasserver_node_tags.tag_id = NEW.id
    AND maasserver_node_tags.node_id = maasserver_node.id)
  LOOP
    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.tag_update_machine_device_notify() OWNER TO gavin;

--
-- Name: tag_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION tag_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('tag_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.tag_update_notify() OWNER TO gavin;

--
-- Name: user_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_create_notify() OWNER TO gavin;

--
-- Name: user_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_delete_notify() OWNER TO gavin;

--
-- Name: user_sshkey_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_sshkey_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_update',CAST(NEW.user_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_sshkey_link_notify() OWNER TO gavin;

--
-- Name: user_sshkey_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_sshkey_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_update',CAST(OLD.user_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_sshkey_unlink_notify() OWNER TO gavin;

--
-- Name: user_sslkey_link_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_sslkey_link_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_update',CAST(NEW.user_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_sslkey_link_notify() OWNER TO gavin;

--
-- Name: user_sslkey_unlink_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_sslkey_unlink_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_update',CAST(OLD.user_id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_sslkey_unlink_notify() OWNER TO gavin;

--
-- Name: user_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION user_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('user_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.user_update_notify() OWNER TO gavin;

--
-- Name: vlan_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION vlan_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('vlan_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.vlan_create_notify() OWNER TO gavin;

--
-- Name: vlan_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION vlan_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('vlan_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.vlan_delete_notify() OWNER TO gavin;

--
-- Name: vlan_machine_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION vlan_machine_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    node RECORD;
    pnode RECORD;
BEGIN
  FOR node IN (
    SELECT DISTINCT ON (maasserver_node.id)
      system_id, node_type, parent_id
    FROM maasserver_node, maasserver_interface, maasserver_vlan
    WHERE maasserver_vlan.id = NEW.id
    AND maasserver_node.id = maasserver_interface.node_id
    AND maasserver_vlan.id = maasserver_interface.vlan_id)
  LOOP
    IF node.node_type = 0 THEN
      PERFORM pg_notify('machine_update',CAST(node.system_id AS text));
    ELSIF node.node_type IN (2, 3, 4) THEN
      PERFORM pg_notify('controller_update',CAST(node.system_id AS text));
    ELSIF node.parent_id IS NOT NULL THEN
      SELECT system_id INTO pnode
      FROM maasserver_node
      WHERE id = node.parent_id;
      PERFORM pg_notify('machine_update',CAST(pnode.system_id AS text));
    ELSE
      PERFORM pg_notify('device_update',CAST(node.system_id AS text));
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.vlan_machine_update_notify() OWNER TO gavin;

--
-- Name: vlan_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION vlan_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('vlan_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.vlan_update_notify() OWNER TO gavin;

--
-- Name: zone_create_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION zone_create_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('zone_create',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.zone_create_notify() OWNER TO gavin;

--
-- Name: zone_delete_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION zone_delete_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('zone_delete',CAST(OLD.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.zone_delete_notify() OWNER TO gavin;

--
-- Name: zone_update_notify(); Type: FUNCTION; Schema: public; Owner: gavin
--

CREATE FUNCTION zone_update_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  PERFORM pg_notify('zone_update',CAST(NEW.id AS text));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.zone_update_notify() OWNER TO gavin;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE auth_group OWNER TO gavin;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_id_seq OWNER TO gavin;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE auth_group_permissions OWNER TO gavin;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_permissions_id_seq OWNER TO gavin;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE auth_group_permissions_id_seq OWNED BY auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE auth_permission OWNER TO gavin;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_permission_id_seq OWNER TO gavin;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE auth_user OWNER TO gavin;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE auth_user_groups OWNER TO gavin;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_groups_id_seq OWNER TO gavin;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE auth_user_groups_id_seq OWNED BY auth_user_groups.id;


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq OWNER TO gavin;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE auth_user_user_permissions OWNER TO gavin;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_user_permissions_id_seq OWNER TO gavin;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE auth_user_user_permissions_id_seq OWNED BY auth_user_user_permissions.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE django_content_type OWNER TO gavin;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE django_content_type_id_seq OWNER TO gavin;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE django_content_type_id_seq OWNED BY django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE django_migrations OWNER TO gavin;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE django_migrations_id_seq OWNER TO gavin;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE django_migrations_id_seq OWNED BY django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE django_session OWNER TO gavin;

--
-- Name: django_site; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE django_site OWNER TO gavin;

--
-- Name: django_site_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE django_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE django_site_id_seq OWNER TO gavin;

--
-- Name: django_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE django_site_id_seq OWNED BY django_site.id;


--
-- Name: maasserver_bootsource; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bootsource (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    url character varying(200) NOT NULL,
    keyring_filename character varying(100) NOT NULL,
    keyring_data bytea NOT NULL
);


ALTER TABLE maasserver_bootsource OWNER TO gavin;

--
-- Name: maasserver_bootsourcecache; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bootsourcecache (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    os character varying(32) NOT NULL,
    arch character varying(32) NOT NULL,
    subarch character varying(32) NOT NULL,
    release character varying(32) NOT NULL,
    label character varying(32) NOT NULL,
    boot_source_id integer NOT NULL,
    release_codename character varying(255),
    release_title character varying(255),
    support_eol date,
    kflavor character varying(32),
    bootloader_type character varying(32)
);


ALTER TABLE maasserver_bootsourcecache OWNER TO gavin;

--
-- Name: maas_support__boot_source_cache; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__boot_source_cache AS
 SELECT bs.url,
    bsc.label,
    bsc.os,
    bsc.release,
    bsc.arch,
    bsc.subarch
   FROM (maasserver_bootsource bs
     LEFT JOIN maasserver_bootsourcecache bsc ON ((bsc.boot_source_id = bs.id)))
  ORDER BY bs.url, bsc.label, bsc.os, bsc.release, bsc.arch, bsc.subarch;


ALTER TABLE maas_support__boot_source_cache OWNER TO gavin;

--
-- Name: maasserver_bootsourceselection; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bootsourceselection (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    os character varying(20) NOT NULL,
    release character varying(20) NOT NULL,
    arches text[],
    subarches text[],
    labels text[],
    boot_source_id integer NOT NULL
);


ALTER TABLE maasserver_bootsourceselection OWNER TO gavin;

--
-- Name: maas_support__boot_source_selections; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__boot_source_selections AS
 SELECT bs.url,
    bss.release,
    bss.arches,
    bss.subarches,
    bss.labels,
    bss.os
   FROM (maasserver_bootsource bs
     LEFT JOIN maasserver_bootsourceselection bss ON ((bss.boot_source_id = bs.id)));


ALTER TABLE maas_support__boot_source_selections OWNER TO gavin;

--
-- Name: metadataserver_noderesult; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE metadataserver_noderesult (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    script_result integer NOT NULL,
    result_type integer NOT NULL,
    name character varying(255) NOT NULL,
    data text NOT NULL,
    node_id integer NOT NULL
);


ALTER TABLE metadataserver_noderesult OWNER TO gavin;

--
-- Name: maas_support__commissioning_result_summary; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__commissioning_result_summary AS
 SELECT node.hostname,
    count(nr.*) AS result_count,
    max(nr.script_result) AS max_script_result,
    max(nr.result_type) AS max_result_type
   FROM (maasserver_node node
     LEFT JOIN metadataserver_noderesult nr ON ((nr.node_id = node.id)))
  WHERE (node.node_type = 0)
  GROUP BY node.hostname
  ORDER BY node.hostname;


ALTER TABLE maas_support__commissioning_result_summary OWNER TO gavin;

--
-- Name: maasserver_config; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_config (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE maasserver_config OWNER TO gavin;

--
-- Name: maas_support__configuration__excluding_rpc_shared_secret; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__configuration__excluding_rpc_shared_secret AS
 SELECT maasserver_config.name,
    maasserver_config.value
   FROM maasserver_config
  WHERE ((maasserver_config.name)::text <> 'rpc_shared_secret'::text);


ALTER TABLE maas_support__configuration__excluding_rpc_shared_secret OWNER TO gavin;

--
-- Name: maas_support__device_overview; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__device_overview AS
 SELECT node.hostname,
    node.system_id,
    parent.hostname AS parent
   FROM (maasserver_node node
     LEFT JOIN maasserver_node parent ON ((node.parent_id = parent.id)))
  WHERE (node.node_type = 1)
  ORDER BY node.hostname;


ALTER TABLE maas_support__device_overview OWNER TO gavin;

--
-- Name: maasserver_licensekey; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_licensekey (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    osystem character varying(255) NOT NULL,
    distro_series character varying(255) NOT NULL,
    license_key character varying(255) NOT NULL
);


ALTER TABLE maasserver_licensekey OWNER TO gavin;

--
-- Name: maas_support__license_keys_present__excluding_key_material; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__license_keys_present__excluding_key_material AS
 SELECT maasserver_licensekey.osystem,
    maasserver_licensekey.distro_series
   FROM maasserver_licensekey;


ALTER TABLE maas_support__license_keys_present__excluding_key_material OWNER TO gavin;

--
-- Name: maasserver_fabric; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_fabric (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256),
    class_type character varying(256),
    description text NOT NULL
);


ALTER TABLE maasserver_fabric OWNER TO gavin;

--
-- Name: maasserver_interface; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_interface (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(20) NOT NULL,
    mac_address macaddr,
    ipv4_params text NOT NULL,
    ipv6_params text NOT NULL,
    params text NOT NULL,
    tags text[],
    enabled boolean NOT NULL,
    node_id integer,
    vlan_id integer,
    acquired boolean NOT NULL,
    mdns_discovery_state boolean NOT NULL,
    neighbour_discovery_state boolean NOT NULL
);


ALTER TABLE maasserver_interface OWNER TO gavin;

--
-- Name: maasserver_interface_ip_addresses; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_interface_ip_addresses (
    id integer NOT NULL,
    interface_id integer NOT NULL,
    staticipaddress_id integer NOT NULL
);


ALTER TABLE maasserver_interface_ip_addresses OWNER TO gavin;

--
-- Name: maasserver_staticipaddress; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_staticipaddress (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    ip inet,
    alloc_type integer NOT NULL,
    subnet_id integer,
    user_id integer,
    lease_time integer NOT NULL
);


ALTER TABLE maasserver_staticipaddress OWNER TO gavin;

--
-- Name: maasserver_subnet; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_subnet (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    cidr cidr NOT NULL,
    gateway_ip inet,
    dns_servers text[],
    vlan_id integer NOT NULL,
    rdns_mode integer NOT NULL,
    allow_proxy boolean NOT NULL,
    description text NOT NULL,
    active_discovery boolean NOT NULL,
    managed boolean NOT NULL
);


ALTER TABLE maasserver_subnet OWNER TO gavin;

--
-- Name: maas_support__node_networking; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__node_networking AS
 SELECT node.hostname,
    iface.id AS ifid,
    iface.name,
    iface.type,
    iface.mac_address,
    sip.ip,
        CASE
            WHEN (sip.alloc_type = 0) THEN 'AUTO'::bpchar
            WHEN (sip.alloc_type = 1) THEN 'STICKY'::bpchar
            WHEN (sip.alloc_type = 4) THEN 'USER_RESERVED'::bpchar
            WHEN (sip.alloc_type = 5) THEN 'DHCP'::bpchar
            WHEN (sip.alloc_type = 6) THEN 'DISCOVERED'::bpchar
            ELSE (sip.alloc_type)::character(1)
        END AS alloc_type,
    subnet.cidr,
    vlan.vid,
    fabric.name AS fabric
   FROM ((((((maasserver_interface iface
     LEFT JOIN maasserver_interface_ip_addresses ifip ON ((ifip.interface_id = iface.id)))
     LEFT JOIN maasserver_staticipaddress sip ON ((ifip.staticipaddress_id = sip.id)))
     LEFT JOIN maasserver_subnet subnet ON ((sip.subnet_id = subnet.id)))
     LEFT JOIN maasserver_node node ON ((node.id = iface.node_id)))
     LEFT JOIN maasserver_vlan vlan ON ((vlan.id = subnet.vlan_id)))
     LEFT JOIN maasserver_fabric fabric ON ((fabric.id = vlan.fabric_id)))
  ORDER BY node.hostname, iface.name, sip.alloc_type;


ALTER TABLE maas_support__node_networking OWNER TO gavin;

--
-- Name: maas_support__node_overview; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__node_overview AS
 SELECT maasserver_node.hostname,
    maasserver_node.system_id,
    maasserver_node.cpu_count AS cpu,
    maasserver_node.memory
   FROM maasserver_node
  WHERE (maasserver_node.node_type = 0)
  ORDER BY maasserver_node.hostname;


ALTER TABLE maas_support__node_overview OWNER TO gavin;

--
-- Name: maasserver_sshkey; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_sshkey (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    key text NOT NULL,
    user_id integer NOT NULL,
    keysource_id integer
);


ALTER TABLE maasserver_sshkey OWNER TO gavin;

--
-- Name: maas_support__ssh_keys__by_user; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maas_support__ssh_keys__by_user AS
 SELECT u.username,
    sshkey.key
   FROM (auth_user u
     LEFT JOIN maasserver_sshkey sshkey ON ((u.id = sshkey.user_id)))
  ORDER BY u.username, sshkey.key;


ALTER TABLE maas_support__ssh_keys__by_user OWNER TO gavin;

--
-- Name: maasserver_blockdevice; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_blockdevice (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    id_path character varying(100),
    size bigint NOT NULL,
    block_size integer NOT NULL,
    tags text[],
    node_id integer NOT NULL
);


ALTER TABLE maasserver_blockdevice OWNER TO gavin;

--
-- Name: maasserver_blockdevice_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_blockdevice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_blockdevice_id_seq OWNER TO gavin;

--
-- Name: maasserver_blockdevice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_blockdevice_id_seq OWNED BY maasserver_blockdevice.id;


--
-- Name: maasserver_bmc; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bmc (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    power_type character varying(10) NOT NULL,
    power_parameters text NOT NULL,
    ip_address_id integer
);


ALTER TABLE maasserver_bmc OWNER TO gavin;

--
-- Name: maasserver_bmc_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bmc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bmc_id_seq OWNER TO gavin;

--
-- Name: maasserver_bmc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bmc_id_seq OWNED BY maasserver_bmc.id;


--
-- Name: maasserver_bmcroutablerackcontrollerrelationship; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bmcroutablerackcontrollerrelationship (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    routable boolean NOT NULL,
    bmc_id integer NOT NULL,
    rack_controller_id integer NOT NULL
);


ALTER TABLE maasserver_bmcroutablerackcontrollerrelationship OWNER TO gavin;

--
-- Name: maasserver_bmcroutablerackcontrollerrelationship_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bmcroutablerackcontrollerrelationship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bmcroutablerackcontrollerrelationship_id_seq OWNER TO gavin;

--
-- Name: maasserver_bmcroutablerackcontrollerrelationship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bmcroutablerackcontrollerrelationship_id_seq OWNED BY maasserver_bmcroutablerackcontrollerrelationship.id;


--
-- Name: maasserver_bootresource; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bootresource (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    rtype integer NOT NULL,
    name character varying(255) NOT NULL,
    architecture character varying(255) NOT NULL,
    extra text NOT NULL,
    kflavor character varying(32),
    bootloader_type character varying(32),
    rolling boolean NOT NULL
);


ALTER TABLE maasserver_bootresource OWNER TO gavin;

--
-- Name: maasserver_bootresource_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bootresource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bootresource_id_seq OWNER TO gavin;

--
-- Name: maasserver_bootresource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bootresource_id_seq OWNED BY maasserver_bootresource.id;


--
-- Name: maasserver_bootresourcefile; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bootresourcefile (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    filename character varying(255) NOT NULL,
    filetype character varying(20) NOT NULL,
    extra text NOT NULL,
    largefile_id integer NOT NULL,
    resource_set_id integer NOT NULL
);


ALTER TABLE maasserver_bootresourcefile OWNER TO gavin;

--
-- Name: maasserver_bootresourcefile_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bootresourcefile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bootresourcefile_id_seq OWNER TO gavin;

--
-- Name: maasserver_bootresourcefile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bootresourcefile_id_seq OWNED BY maasserver_bootresourcefile.id;


--
-- Name: maasserver_bootresourceset; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_bootresourceset (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    version character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    resource_id integer NOT NULL
);


ALTER TABLE maasserver_bootresourceset OWNER TO gavin;

--
-- Name: maasserver_bootresourceset_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bootresourceset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bootresourceset_id_seq OWNER TO gavin;

--
-- Name: maasserver_bootresourceset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bootresourceset_id_seq OWNED BY maasserver_bootresourceset.id;


--
-- Name: maasserver_bootsource_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bootsource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bootsource_id_seq OWNER TO gavin;

--
-- Name: maasserver_bootsource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bootsource_id_seq OWNED BY maasserver_bootsource.id;


--
-- Name: maasserver_bootsourcecache_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bootsourcecache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bootsourcecache_id_seq OWNER TO gavin;

--
-- Name: maasserver_bootsourcecache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bootsourcecache_id_seq OWNED BY maasserver_bootsourcecache.id;


--
-- Name: maasserver_bootsourceselection_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_bootsourceselection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_bootsourceselection_id_seq OWNER TO gavin;

--
-- Name: maasserver_bootsourceselection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_bootsourceselection_id_seq OWNED BY maasserver_bootsourceselection.id;


--
-- Name: maasserver_cacheset; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_cacheset (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL
);


ALTER TABLE maasserver_cacheset OWNER TO gavin;

--
-- Name: maasserver_cacheset_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_cacheset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_cacheset_id_seq OWNER TO gavin;

--
-- Name: maasserver_cacheset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_cacheset_id_seq OWNED BY maasserver_cacheset.id;


--
-- Name: maasserver_chassishints; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_chassishints (
    id integer NOT NULL,
    cores integer NOT NULL,
    memory integer NOT NULL,
    local_storage integer NOT NULL,
    chassis_id integer NOT NULL
);


ALTER TABLE maasserver_chassishints OWNER TO gavin;

--
-- Name: maasserver_chassishints_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_chassishints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_chassishints_id_seq OWNER TO gavin;

--
-- Name: maasserver_chassishints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_chassishints_id_seq OWNED BY maasserver_chassishints.id;


--
-- Name: maasserver_componenterror; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_componenterror (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    component character varying(40) NOT NULL,
    error character varying(1000) NOT NULL
);


ALTER TABLE maasserver_componenterror OWNER TO gavin;

--
-- Name: maasserver_componenterror_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_componenterror_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_componenterror_id_seq OWNER TO gavin;

--
-- Name: maasserver_componenterror_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_componenterror_id_seq OWNED BY maasserver_componenterror.id;


--
-- Name: maasserver_config_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_config_id_seq OWNER TO gavin;

--
-- Name: maasserver_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_config_id_seq OWNED BY maasserver_config.id;


--
-- Name: maasserver_dhcpsnippet_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_dhcpsnippet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_dhcpsnippet_id_seq OWNER TO gavin;

--
-- Name: maasserver_dhcpsnippet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_dhcpsnippet_id_seq OWNED BY maasserver_dhcpsnippet.id;


--
-- Name: maasserver_mdns; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_mdns (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    ip inet,
    hostname character varying(256),
    count integer NOT NULL,
    interface_id integer NOT NULL
);


ALTER TABLE maasserver_mdns OWNER TO gavin;

--
-- Name: maasserver_neighbour; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_neighbour (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    ip inet,
    "time" integer NOT NULL,
    vid integer,
    count integer NOT NULL,
    mac_address macaddr,
    interface_id integer NOT NULL
);


ALTER TABLE maasserver_neighbour OWNER TO gavin;

--
-- Name: maasserver_rdns; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_rdns (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    ip inet NOT NULL,
    hostname character varying(256),
    hostnames text NOT NULL,
    observer_id integer NOT NULL
);


ALTER TABLE maasserver_rdns OWNER TO gavin;

--
-- Name: maasserver_discovery; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maasserver_discovery AS
 SELECT DISTINCT ON (neigh.mac_address, neigh.ip) neigh.id,
    replace(encode((((rtrim((neigh.ip)::text, '/32'::text) || ','::text) || (neigh.mac_address)::text))::bytea, 'base64'::text), chr(10), ''::text) AS discovery_id,
    neigh.id AS neighbour_id,
    neigh.ip,
    neigh.mac_address,
    neigh.vid,
    neigh.created AS first_seen,
    GREATEST(neigh.updated, mdns.updated) AS last_seen,
    mdns.id AS mdns_id,
    COALESCE(rdns.hostname, mdns.hostname) AS hostname,
    node.id AS observer_id,
    node.system_id AS observer_system_id,
    node.hostname AS observer_hostname,
    iface.id AS observer_interface_id,
    iface.name AS observer_interface_name,
    fabric.id AS fabric_id,
    fabric.name AS fabric_name,
    vlan.id AS vlan_id,
        CASE
            WHEN (neigh.ip = vlan.external_dhcp) THEN true
            ELSE false
        END AS is_external_dhcp,
    subnet.id AS subnet_id,
    subnet.cidr AS subnet_cidr,
    masklen((subnet.cidr)::inet) AS subnet_prefixlen
   FROM (((((((maasserver_neighbour neigh
     JOIN maasserver_interface iface ON ((neigh.interface_id = iface.id)))
     JOIN maasserver_node node ON ((node.id = iface.node_id)))
     JOIN maasserver_vlan vlan ON ((iface.vlan_id = vlan.id)))
     JOIN maasserver_fabric fabric ON ((vlan.fabric_id = fabric.id)))
     LEFT JOIN maasserver_mdns mdns ON ((mdns.ip = neigh.ip)))
     LEFT JOIN maasserver_rdns rdns ON ((rdns.ip = neigh.ip)))
     LEFT JOIN maasserver_subnet subnet ON (((vlan.id = subnet.vlan_id) AND (neigh.ip << (subnet.cidr)::inet))))
  ORDER BY neigh.mac_address, neigh.ip, neigh.updated DESC, rdns.updated DESC, mdns.updated DESC, (masklen((subnet.cidr)::inet)) DESC;


ALTER TABLE maasserver_discovery OWNER TO gavin;

--
-- Name: maasserver_dnsdata; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_dnsdata (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    rrtype character varying(8) NOT NULL,
    rrdata text NOT NULL,
    dnsresource_id integer NOT NULL,
    ttl integer,
    CONSTRAINT maasserver_dnsdata_ttl_check CHECK ((ttl >= 0))
);


ALTER TABLE maasserver_dnsdata OWNER TO gavin;

--
-- Name: maasserver_dnsdata_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_dnsdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_dnsdata_id_seq OWNER TO gavin;

--
-- Name: maasserver_dnsdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_dnsdata_id_seq OWNED BY maasserver_dnsdata.id;


--
-- Name: maasserver_dnspublication; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_dnspublication (
    id integer NOT NULL,
    serial bigint NOT NULL,
    created timestamp with time zone NOT NULL,
    source character varying(255) NOT NULL
);


ALTER TABLE maasserver_dnspublication OWNER TO gavin;

--
-- Name: maasserver_dnspublication_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_dnspublication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_dnspublication_id_seq OWNER TO gavin;

--
-- Name: maasserver_dnspublication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_dnspublication_id_seq OWNED BY maasserver_dnspublication.id;


--
-- Name: maasserver_dnsresource; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_dnsresource (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(191),
    domain_id integer NOT NULL,
    address_ttl integer,
    CONSTRAINT maasserver_dnsresource_address_ttl_check CHECK ((address_ttl >= 0))
);


ALTER TABLE maasserver_dnsresource OWNER TO gavin;

--
-- Name: maasserver_dnsresource_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_dnsresource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_dnsresource_id_seq OWNER TO gavin;

--
-- Name: maasserver_dnsresource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_dnsresource_id_seq OWNED BY maasserver_dnsresource.id;


--
-- Name: maasserver_dnsresource_ip_addresses; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_dnsresource_ip_addresses (
    id integer NOT NULL,
    dnsresource_id integer NOT NULL,
    staticipaddress_id integer NOT NULL
);


ALTER TABLE maasserver_dnsresource_ip_addresses OWNER TO gavin;

--
-- Name: maasserver_dnsresource_ip_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_dnsresource_ip_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_dnsresource_ip_addresses_id_seq OWNER TO gavin;

--
-- Name: maasserver_dnsresource_ip_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_dnsresource_ip_addresses_id_seq OWNED BY maasserver_dnsresource_ip_addresses.id;


--
-- Name: maasserver_domain; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_domain (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256) NOT NULL,
    authoritative boolean,
    ttl integer,
    CONSTRAINT maasserver_domain_ttl_check CHECK ((ttl >= 0))
);


ALTER TABLE maasserver_domain OWNER TO gavin;

--
-- Name: maasserver_domain_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_domain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_domain_id_seq OWNER TO gavin;

--
-- Name: maasserver_domain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_domain_id_seq OWNED BY maasserver_domain.id;


--
-- Name: maasserver_event; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_event (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    action text NOT NULL,
    description text NOT NULL,
    node_id integer NOT NULL,
    type_id integer NOT NULL
);


ALTER TABLE maasserver_event OWNER TO gavin;

--
-- Name: maasserver_event_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_event_id_seq OWNER TO gavin;

--
-- Name: maasserver_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_event_id_seq OWNED BY maasserver_event.id;


--
-- Name: maasserver_eventtype; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_eventtype (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    level integer NOT NULL
);


ALTER TABLE maasserver_eventtype OWNER TO gavin;

--
-- Name: maasserver_eventtype_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_eventtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_eventtype_id_seq OWNER TO gavin;

--
-- Name: maasserver_eventtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_eventtype_id_seq OWNED BY maasserver_eventtype.id;


--
-- Name: maasserver_fabric_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_fabric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_fabric_id_seq OWNER TO gavin;

--
-- Name: maasserver_fabric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_fabric_id_seq OWNED BY maasserver_fabric.id;


--
-- Name: maasserver_fannetwork; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_fannetwork (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256) NOT NULL,
    "overlay" cidr NOT NULL,
    underlay cidr NOT NULL,
    dhcp boolean,
    host_reserve integer,
    bridge character varying(255),
    off boolean,
    CONSTRAINT maasserver_fannetwork_host_reserve_check CHECK ((host_reserve >= 0))
);


ALTER TABLE maasserver_fannetwork OWNER TO gavin;

--
-- Name: maasserver_fannetwork_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_fannetwork_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_fannetwork_id_seq OWNER TO gavin;

--
-- Name: maasserver_fannetwork_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_fannetwork_id_seq OWNED BY maasserver_fannetwork.id;


--
-- Name: maasserver_filestorage; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_filestorage (
    id integer NOT NULL,
    filename character varying(255) NOT NULL,
    content text NOT NULL,
    key character varying(36) NOT NULL,
    owner_id integer
);


ALTER TABLE maasserver_filestorage OWNER TO gavin;

--
-- Name: maasserver_filestorage_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_filestorage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_filestorage_id_seq OWNER TO gavin;

--
-- Name: maasserver_filestorage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_filestorage_id_seq OWNED BY maasserver_filestorage.id;


--
-- Name: maasserver_filesystem; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_filesystem (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    uuid character varying(36) NOT NULL,
    fstype character varying(20) NOT NULL,
    label character varying(255),
    create_params character varying(255),
    mount_point character varying(255),
    mount_options character varying(255),
    acquired boolean NOT NULL,
    block_device_id integer,
    cache_set_id integer,
    filesystem_group_id integer,
    partition_id integer,
    node_id integer
);


ALTER TABLE maasserver_filesystem OWNER TO gavin;

--
-- Name: maasserver_filesystem_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_filesystem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_filesystem_id_seq OWNER TO gavin;

--
-- Name: maasserver_filesystem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_filesystem_id_seq OWNED BY maasserver_filesystem.id;


--
-- Name: maasserver_filesystemgroup; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_filesystemgroup (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    uuid character varying(36) NOT NULL,
    group_type character varying(20) NOT NULL,
    name character varying(255) NOT NULL,
    create_params character varying(255),
    cache_mode character varying(20),
    cache_set_id integer
);


ALTER TABLE maasserver_filesystemgroup OWNER TO gavin;

--
-- Name: maasserver_filesystemgroup_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_filesystemgroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_filesystemgroup_id_seq OWNER TO gavin;

--
-- Name: maasserver_filesystemgroup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_filesystemgroup_id_seq OWNED BY maasserver_filesystemgroup.id;


--
-- Name: maasserver_interface_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_interface_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_interface_id_seq OWNER TO gavin;

--
-- Name: maasserver_interface_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_interface_id_seq OWNED BY maasserver_interface.id;


--
-- Name: maasserver_interface_ip_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_interface_ip_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_interface_ip_addresses_id_seq OWNER TO gavin;

--
-- Name: maasserver_interface_ip_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_interface_ip_addresses_id_seq OWNED BY maasserver_interface_ip_addresses.id;


--
-- Name: maasserver_interfacerelationship; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_interfacerelationship (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    child_id integer NOT NULL,
    parent_id integer NOT NULL
);


ALTER TABLE maasserver_interfacerelationship OWNER TO gavin;

--
-- Name: maasserver_interfacerelationship_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_interfacerelationship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_interfacerelationship_id_seq OWNER TO gavin;

--
-- Name: maasserver_interfacerelationship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_interfacerelationship_id_seq OWNED BY maasserver_interfacerelationship.id;


--
-- Name: maasserver_iprange; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_iprange (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    type character varying(20) NOT NULL,
    start_ip inet NOT NULL,
    end_ip inet NOT NULL,
    comment character varying(255),
    subnet_id integer NOT NULL,
    user_id integer
);


ALTER TABLE maasserver_iprange OWNER TO gavin;

--
-- Name: maasserver_iprange_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_iprange_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_iprange_id_seq OWNER TO gavin;

--
-- Name: maasserver_iprange_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_iprange_id_seq OWNED BY maasserver_iprange.id;


--
-- Name: maasserver_keysource; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_keysource (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    protocol character varying(64) NOT NULL,
    auth_id character varying(255) NOT NULL,
    auto_update boolean NOT NULL
);


ALTER TABLE maasserver_keysource OWNER TO gavin;

--
-- Name: maasserver_keysource_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_keysource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_keysource_id_seq OWNER TO gavin;

--
-- Name: maasserver_keysource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_keysource_id_seq OWNED BY maasserver_keysource.id;


--
-- Name: maasserver_largefile; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_largefile (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    sha256 character varying(64) NOT NULL,
    total_size bigint NOT NULL,
    content oid NOT NULL,
    size bigint NOT NULL
);


ALTER TABLE maasserver_largefile OWNER TO gavin;

--
-- Name: maasserver_largefile_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_largefile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_largefile_id_seq OWNER TO gavin;

--
-- Name: maasserver_largefile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_largefile_id_seq OWNED BY maasserver_largefile.id;


--
-- Name: maasserver_licensekey_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_licensekey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_licensekey_id_seq OWNER TO gavin;

--
-- Name: maasserver_licensekey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_licensekey_id_seq OWNED BY maasserver_licensekey.id;


--
-- Name: maasserver_mdns_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_mdns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_mdns_id_seq OWNER TO gavin;

--
-- Name: maasserver_mdns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_mdns_id_seq OWNED BY maasserver_mdns.id;


--
-- Name: maasserver_neighbour_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_neighbour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_neighbour_id_seq OWNER TO gavin;

--
-- Name: maasserver_neighbour_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_neighbour_id_seq OWNED BY maasserver_neighbour.id;


--
-- Name: maasserver_node_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_node_id_seq OWNER TO gavin;

--
-- Name: maasserver_node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_node_id_seq OWNED BY maasserver_node.id;


--
-- Name: maasserver_node_tags; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_node_tags (
    id integer NOT NULL,
    node_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE maasserver_node_tags OWNER TO gavin;

--
-- Name: maasserver_node_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_node_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_node_tags_id_seq OWNER TO gavin;

--
-- Name: maasserver_node_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_node_tags_id_seq OWNED BY maasserver_node_tags.id;


--
-- Name: maasserver_nodegrouptorackcontroller; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_nodegrouptorackcontroller (
    id integer NOT NULL,
    uuid character varying(36) NOT NULL,
    subnet_id integer NOT NULL
);


ALTER TABLE maasserver_nodegrouptorackcontroller OWNER TO gavin;

--
-- Name: maasserver_nodegrouptorackcontroller_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_nodegrouptorackcontroller_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_nodegrouptorackcontroller_id_seq OWNER TO gavin;

--
-- Name: maasserver_nodegrouptorackcontroller_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_nodegrouptorackcontroller_id_seq OWNED BY maasserver_nodegrouptorackcontroller.id;


--
-- Name: maasserver_notification; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_notification (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    ident character varying(40),
    users boolean NOT NULL,
    admins boolean NOT NULL,
    message text NOT NULL,
    context text NOT NULL,
    user_id integer
);


ALTER TABLE maasserver_notification OWNER TO gavin;

--
-- Name: maasserver_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_notification_id_seq OWNER TO gavin;

--
-- Name: maasserver_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_notification_id_seq OWNED BY maasserver_notification.id;


--
-- Name: maasserver_ownerdata; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_ownerdata (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL,
    node_id integer NOT NULL
);


ALTER TABLE maasserver_ownerdata OWNER TO gavin;

--
-- Name: maasserver_ownerdata_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_ownerdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_ownerdata_id_seq OWNER TO gavin;

--
-- Name: maasserver_ownerdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_ownerdata_id_seq OWNED BY maasserver_ownerdata.id;


--
-- Name: maasserver_packagerepository; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_packagerepository (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(41) NOT NULL,
    url character varying(200) NOT NULL,
    components text[],
    arches text[],
    key text NOT NULL,
    "default" boolean NOT NULL,
    enabled boolean NOT NULL,
    disabled_pockets text[],
    distributions text[]
);


ALTER TABLE maasserver_packagerepository OWNER TO gavin;

--
-- Name: maasserver_packagerepository_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_packagerepository_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_packagerepository_id_seq OWNER TO gavin;

--
-- Name: maasserver_packagerepository_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_packagerepository_id_seq OWNED BY maasserver_packagerepository.id;


--
-- Name: maasserver_partition; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_partition (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    uuid character varying(36),
    size bigint NOT NULL,
    bootable boolean NOT NULL,
    partition_table_id integer NOT NULL
);


ALTER TABLE maasserver_partition OWNER TO gavin;

--
-- Name: maasserver_partition_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_partition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_partition_id_seq OWNER TO gavin;

--
-- Name: maasserver_partition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_partition_id_seq OWNED BY maasserver_partition.id;


--
-- Name: maasserver_partitiontable; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_partitiontable (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    table_type character varying(20) NOT NULL,
    block_device_id integer NOT NULL
);


ALTER TABLE maasserver_partitiontable OWNER TO gavin;

--
-- Name: maasserver_partitiontable_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_partitiontable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_partitiontable_id_seq OWNER TO gavin;

--
-- Name: maasserver_partitiontable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_partitiontable_id_seq OWNED BY maasserver_partitiontable.id;


--
-- Name: maasserver_physicalblockdevice; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_physicalblockdevice (
    blockdevice_ptr_id integer NOT NULL,
    model character varying(255) NOT NULL,
    serial character varying(255) NOT NULL
);


ALTER TABLE maasserver_physicalblockdevice OWNER TO gavin;

--
-- Name: maasserver_rdns_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_rdns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_rdns_id_seq OWNER TO gavin;

--
-- Name: maasserver_rdns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_rdns_id_seq OWNED BY maasserver_rdns.id;


--
-- Name: maasserver_regioncontrollerprocess_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_regioncontrollerprocess_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_regioncontrollerprocess_id_seq OWNER TO gavin;

--
-- Name: maasserver_regioncontrollerprocess_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_regioncontrollerprocess_id_seq OWNED BY maasserver_regioncontrollerprocess.id;


--
-- Name: maasserver_regioncontrollerprocessendpoint; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_regioncontrollerprocessendpoint (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    address inet NOT NULL,
    port integer NOT NULL,
    process_id integer NOT NULL
);


ALTER TABLE maasserver_regioncontrollerprocessendpoint OWNER TO gavin;

--
-- Name: maasserver_regioncontrollerprocessendpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_regioncontrollerprocessendpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_regioncontrollerprocessendpoint_id_seq OWNER TO gavin;

--
-- Name: maasserver_regioncontrollerprocessendpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_regioncontrollerprocessendpoint_id_seq OWNED BY maasserver_regioncontrollerprocessendpoint.id;


--
-- Name: maasserver_regionrackrpcconnection; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_regionrackrpcconnection (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    endpoint_id integer NOT NULL,
    rack_controller_id integer NOT NULL
);


ALTER TABLE maasserver_regionrackrpcconnection OWNER TO gavin;

--
-- Name: maasserver_regionrackrpcconnection_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_regionrackrpcconnection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_regionrackrpcconnection_id_seq OWNER TO gavin;

--
-- Name: maasserver_regionrackrpcconnection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_regionrackrpcconnection_id_seq OWNED BY maasserver_regionrackrpcconnection.id;


--
-- Name: maasserver_routable_pairs; Type: VIEW; Schema: public; Owner: gavin
--

CREATE VIEW maasserver_routable_pairs AS
 SELECT if_left.node_id AS left_node_id,
    if_left.id AS left_interface_id,
    subnet_left.id AS left_subnet_id,
    vlan_left.id AS left_vlan_id,
    sip_left.ip AS left_ip,
    if_right.node_id AS right_node_id,
    if_right.id AS right_interface_id,
    subnet_right.id AS right_subnet_id,
    vlan_right.id AS right_vlan_id,
    sip_right.ip AS right_ip,
    vlan_left.space_id
   FROM (((((((((maasserver_interface if_left
     JOIN maasserver_interface_ip_addresses ifia_left ON ((if_left.id = ifia_left.interface_id)))
     JOIN maasserver_staticipaddress sip_left ON ((ifia_left.staticipaddress_id = sip_left.id)))
     JOIN maasserver_subnet subnet_left ON ((sip_left.subnet_id = subnet_left.id)))
     JOIN maasserver_vlan vlan_left ON ((subnet_left.vlan_id = vlan_left.id)))
     JOIN maasserver_vlan vlan_right ON ((NOT (vlan_left.space_id IS DISTINCT FROM vlan_right.space_id))))
     JOIN maasserver_subnet subnet_right ON ((vlan_right.id = subnet_right.vlan_id)))
     JOIN maasserver_staticipaddress sip_right ON ((subnet_right.id = sip_right.subnet_id)))
     JOIN maasserver_interface_ip_addresses ifia_right ON ((sip_right.id = ifia_right.staticipaddress_id)))
     JOIN maasserver_interface if_right ON ((ifia_right.interface_id = if_right.id)))
  WHERE (if_left.enabled AND (sip_left.ip IS NOT NULL) AND if_right.enabled AND (sip_right.ip IS NOT NULL) AND (family(sip_left.ip) = family(sip_right.ip)));


ALTER TABLE maasserver_routable_pairs OWNER TO gavin;

--
-- Name: maasserver_service; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_service (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    status character varying(10) NOT NULL,
    status_info character varying(255) NOT NULL,
    node_id integer NOT NULL
);


ALTER TABLE maasserver_service OWNER TO gavin;

--
-- Name: maasserver_service_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_service_id_seq OWNER TO gavin;

--
-- Name: maasserver_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_service_id_seq OWNED BY maasserver_service.id;


--
-- Name: maasserver_space; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_space (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256),
    description text NOT NULL
);


ALTER TABLE maasserver_space OWNER TO gavin;

--
-- Name: maasserver_space_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_space_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_space_id_seq OWNER TO gavin;

--
-- Name: maasserver_space_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_space_id_seq OWNED BY maasserver_space.id;


--
-- Name: maasserver_sshkey_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_sshkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_sshkey_id_seq OWNER TO gavin;

--
-- Name: maasserver_sshkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_sshkey_id_seq OWNED BY maasserver_sshkey.id;


--
-- Name: maasserver_sslkey; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_sslkey (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    key text NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE maasserver_sslkey OWNER TO gavin;

--
-- Name: maasserver_sslkey_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_sslkey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_sslkey_id_seq OWNER TO gavin;

--
-- Name: maasserver_sslkey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_sslkey_id_seq OWNED BY maasserver_sslkey.id;


--
-- Name: maasserver_staticipaddress_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_staticipaddress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_staticipaddress_id_seq OWNER TO gavin;

--
-- Name: maasserver_staticipaddress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_staticipaddress_id_seq OWNED BY maasserver_staticipaddress.id;


--
-- Name: maasserver_staticroute; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_staticroute (
    id integer NOT NULL,
    gateway_ip inet NOT NULL,
    metric integer NOT NULL,
    destination_id integer NOT NULL,
    source_id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    CONSTRAINT maasserver_staticroute_metric_check CHECK ((metric >= 0))
);


ALTER TABLE maasserver_staticroute OWNER TO gavin;

--
-- Name: maasserver_staticroute_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_staticroute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_staticroute_id_seq OWNER TO gavin;

--
-- Name: maasserver_staticroute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_staticroute_id_seq OWNED BY maasserver_staticroute.id;


--
-- Name: maasserver_subnet_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_subnet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_subnet_id_seq OWNER TO gavin;

--
-- Name: maasserver_subnet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_subnet_id_seq OWNED BY maasserver_subnet.id;


--
-- Name: maasserver_tag; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_tag (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256) NOT NULL,
    definition text NOT NULL,
    comment text NOT NULL,
    kernel_opts text
);


ALTER TABLE maasserver_tag OWNER TO gavin;

--
-- Name: maasserver_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_tag_id_seq OWNER TO gavin;

--
-- Name: maasserver_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_tag_id_seq OWNED BY maasserver_tag.id;


--
-- Name: maasserver_template; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_template (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    filename character varying(64) NOT NULL,
    default_version_id integer NOT NULL,
    version_id integer
);


ALTER TABLE maasserver_template OWNER TO gavin;

--
-- Name: maasserver_template_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_template_id_seq OWNER TO gavin;

--
-- Name: maasserver_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_template_id_seq OWNED BY maasserver_template.id;


--
-- Name: maasserver_userprofile; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_userprofile (
    id integer NOT NULL,
    user_id integer NOT NULL,
    completed_intro boolean NOT NULL
);


ALTER TABLE maasserver_userprofile OWNER TO gavin;

--
-- Name: maasserver_userprofile_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_userprofile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_userprofile_id_seq OWNER TO gavin;

--
-- Name: maasserver_userprofile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_userprofile_id_seq OWNED BY maasserver_userprofile.id;


--
-- Name: maasserver_versionedtextfile; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_versionedtextfile (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    data text,
    comment character varying(255),
    previous_version_id integer
);


ALTER TABLE maasserver_versionedtextfile OWNER TO gavin;

--
-- Name: maasserver_versionedtextfile_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_versionedtextfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_versionedtextfile_id_seq OWNER TO gavin;

--
-- Name: maasserver_versionedtextfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_versionedtextfile_id_seq OWNED BY maasserver_versionedtextfile.id;


--
-- Name: maasserver_virtualblockdevice; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_virtualblockdevice (
    blockdevice_ptr_id integer NOT NULL,
    uuid character varying(36) NOT NULL,
    filesystem_group_id integer NOT NULL
);


ALTER TABLE maasserver_virtualblockdevice OWNER TO gavin;

--
-- Name: maasserver_vlan_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_vlan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_vlan_id_seq OWNER TO gavin;

--
-- Name: maasserver_vlan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_vlan_id_seq OWNED BY maasserver_vlan.id;


--
-- Name: maasserver_zone; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE maasserver_zone (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    updated timestamp with time zone NOT NULL,
    name character varying(256) NOT NULL,
    description text NOT NULL
);


ALTER TABLE maasserver_zone OWNER TO gavin;

--
-- Name: maasserver_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_zone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maasserver_zone_id_seq OWNER TO gavin;

--
-- Name: maasserver_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_zone_id_seq OWNED BY maasserver_zone.id;


--
-- Name: maasserver_zone_serial_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE maasserver_zone_serial_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 4294967295
    CACHE 1
    CYCLE;


ALTER TABLE maasserver_zone_serial_seq OWNER TO gavin;

--
-- Name: maasserver_zone_serial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE maasserver_zone_serial_seq OWNED BY maasserver_dnspublication.serial;


--
-- Name: metadataserver_commissioningscript; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE metadataserver_commissioningscript (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content text NOT NULL
);


ALTER TABLE metadataserver_commissioningscript OWNER TO gavin;

--
-- Name: metadataserver_commissioningscript_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE metadataserver_commissioningscript_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE metadataserver_commissioningscript_id_seq OWNER TO gavin;

--
-- Name: metadataserver_commissioningscript_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE metadataserver_commissioningscript_id_seq OWNED BY metadataserver_commissioningscript.id;


--
-- Name: metadataserver_nodekey; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE metadataserver_nodekey (
    id integer NOT NULL,
    key character varying(18) NOT NULL,
    node_id integer NOT NULL,
    token_id integer NOT NULL
);


ALTER TABLE metadataserver_nodekey OWNER TO gavin;

--
-- Name: metadataserver_nodekey_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE metadataserver_nodekey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE metadataserver_nodekey_id_seq OWNER TO gavin;

--
-- Name: metadataserver_nodekey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE metadataserver_nodekey_id_seq OWNED BY metadataserver_nodekey.id;


--
-- Name: metadataserver_noderesult_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE metadataserver_noderesult_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE metadataserver_noderesult_id_seq OWNER TO gavin;

--
-- Name: metadataserver_noderesult_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE metadataserver_noderesult_id_seq OWNED BY metadataserver_noderesult.id;


--
-- Name: metadataserver_nodeuserdata; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE metadataserver_nodeuserdata (
    id integer NOT NULL,
    data text NOT NULL,
    node_id integer NOT NULL
);


ALTER TABLE metadataserver_nodeuserdata OWNER TO gavin;

--
-- Name: metadataserver_nodeuserdata_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE metadataserver_nodeuserdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE metadataserver_nodeuserdata_id_seq OWNER TO gavin;

--
-- Name: metadataserver_nodeuserdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE metadataserver_nodeuserdata_id_seq OWNED BY metadataserver_nodeuserdata.id;


--
-- Name: piston3_consumer; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE piston3_consumer (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    key character varying(18) NOT NULL,
    secret character varying(32) NOT NULL,
    status character varying(16) NOT NULL,
    user_id integer
);


ALTER TABLE piston3_consumer OWNER TO gavin;

--
-- Name: piston3_consumer_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE piston3_consumer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE piston3_consumer_id_seq OWNER TO gavin;

--
-- Name: piston3_consumer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE piston3_consumer_id_seq OWNED BY piston3_consumer.id;


--
-- Name: piston3_nonce; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE piston3_nonce (
    id integer NOT NULL,
    token_key character varying(18) NOT NULL,
    consumer_key character varying(18) NOT NULL,
    key character varying(255) NOT NULL
);


ALTER TABLE piston3_nonce OWNER TO gavin;

--
-- Name: piston3_nonce_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE piston3_nonce_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE piston3_nonce_id_seq OWNER TO gavin;

--
-- Name: piston3_nonce_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE piston3_nonce_id_seq OWNED BY piston3_nonce.id;


--
-- Name: piston3_token; Type: TABLE; Schema: public; Owner: gavin
--

CREATE TABLE piston3_token (
    id integer NOT NULL,
    key character varying(18) NOT NULL,
    secret character varying(32) NOT NULL,
    verifier character varying(10) NOT NULL,
    token_type integer NOT NULL,
    "timestamp" integer NOT NULL,
    is_approved boolean NOT NULL,
    callback character varying(255),
    callback_confirmed boolean NOT NULL,
    consumer_id integer NOT NULL,
    user_id integer
);


ALTER TABLE piston3_token OWNER TO gavin;

--
-- Name: piston3_token_id_seq; Type: SEQUENCE; Schema: public; Owner: gavin
--

CREATE SEQUENCE piston3_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE piston3_token_id_seq OWNER TO gavin;

--
-- Name: piston3_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gavin
--

ALTER SEQUENCE piston3_token_id_seq OWNED BY piston3_token.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('auth_group_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_groups ALTER COLUMN id SET DEFAULT nextval('auth_user_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('auth_user_user_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_content_type ALTER COLUMN id SET DEFAULT nextval('django_content_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_migrations ALTER COLUMN id SET DEFAULT nextval('django_migrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_site ALTER COLUMN id SET DEFAULT nextval('django_site_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_blockdevice ALTER COLUMN id SET DEFAULT nextval('maasserver_blockdevice_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmc ALTER COLUMN id SET DEFAULT nextval('maasserver_bmc_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmcroutablerackcontrollerrelationship ALTER COLUMN id SET DEFAULT nextval('maasserver_bmcroutablerackcontrollerrelationship_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresource ALTER COLUMN id SET DEFAULT nextval('maasserver_bootresource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourcefile ALTER COLUMN id SET DEFAULT nextval('maasserver_bootresourcefile_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourceset ALTER COLUMN id SET DEFAULT nextval('maasserver_bootresourceset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsource ALTER COLUMN id SET DEFAULT nextval('maasserver_bootsource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourcecache ALTER COLUMN id SET DEFAULT nextval('maasserver_bootsourcecache_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourceselection ALTER COLUMN id SET DEFAULT nextval('maasserver_bootsourceselection_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_cacheset ALTER COLUMN id SET DEFAULT nextval('maasserver_cacheset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_chassishints ALTER COLUMN id SET DEFAULT nextval('maasserver_chassishints_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_componenterror ALTER COLUMN id SET DEFAULT nextval('maasserver_componenterror_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_config ALTER COLUMN id SET DEFAULT nextval('maasserver_config_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dhcpsnippet ALTER COLUMN id SET DEFAULT nextval('maasserver_dhcpsnippet_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsdata ALTER COLUMN id SET DEFAULT nextval('maasserver_dnsdata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnspublication ALTER COLUMN id SET DEFAULT nextval('maasserver_dnspublication_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource ALTER COLUMN id SET DEFAULT nextval('maasserver_dnsresource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource_ip_addresses ALTER COLUMN id SET DEFAULT nextval('maasserver_dnsresource_ip_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_domain ALTER COLUMN id SET DEFAULT nextval('maasserver_domain_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_event ALTER COLUMN id SET DEFAULT nextval('maasserver_event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_eventtype ALTER COLUMN id SET DEFAULT nextval('maasserver_eventtype_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fabric ALTER COLUMN id SET DEFAULT nextval('maasserver_fabric_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fannetwork ALTER COLUMN id SET DEFAULT nextval('maasserver_fannetwork_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filestorage ALTER COLUMN id SET DEFAULT nextval('maasserver_filestorage_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem ALTER COLUMN id SET DEFAULT nextval('maasserver_filesystem_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystemgroup ALTER COLUMN id SET DEFAULT nextval('maasserver_filesystemgroup_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface ALTER COLUMN id SET DEFAULT nextval('maasserver_interface_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface_ip_addresses ALTER COLUMN id SET DEFAULT nextval('maasserver_interface_ip_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interfacerelationship ALTER COLUMN id SET DEFAULT nextval('maasserver_interfacerelationship_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_iprange ALTER COLUMN id SET DEFAULT nextval('maasserver_iprange_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_keysource ALTER COLUMN id SET DEFAULT nextval('maasserver_keysource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_largefile ALTER COLUMN id SET DEFAULT nextval('maasserver_largefile_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_licensekey ALTER COLUMN id SET DEFAULT nextval('maasserver_licensekey_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_mdns ALTER COLUMN id SET DEFAULT nextval('maasserver_mdns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_neighbour ALTER COLUMN id SET DEFAULT nextval('maasserver_neighbour_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node ALTER COLUMN id SET DEFAULT nextval('maasserver_node_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node_tags ALTER COLUMN id SET DEFAULT nextval('maasserver_node_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_nodegrouptorackcontroller ALTER COLUMN id SET DEFAULT nextval('maasserver_nodegrouptorackcontroller_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_notification ALTER COLUMN id SET DEFAULT nextval('maasserver_notification_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_ownerdata ALTER COLUMN id SET DEFAULT nextval('maasserver_ownerdata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_packagerepository ALTER COLUMN id SET DEFAULT nextval('maasserver_packagerepository_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partition ALTER COLUMN id SET DEFAULT nextval('maasserver_partition_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partitiontable ALTER COLUMN id SET DEFAULT nextval('maasserver_partitiontable_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_rdns ALTER COLUMN id SET DEFAULT nextval('maasserver_rdns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocess ALTER COLUMN id SET DEFAULT nextval('maasserver_regioncontrollerprocess_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocessendpoint ALTER COLUMN id SET DEFAULT nextval('maasserver_regioncontrollerprocessendpoint_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regionrackrpcconnection ALTER COLUMN id SET DEFAULT nextval('maasserver_regionrackrpcconnection_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_service ALTER COLUMN id SET DEFAULT nextval('maasserver_service_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_space ALTER COLUMN id SET DEFAULT nextval('maasserver_space_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sshkey ALTER COLUMN id SET DEFAULT nextval('maasserver_sshkey_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sslkey ALTER COLUMN id SET DEFAULT nextval('maasserver_sslkey_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticipaddress ALTER COLUMN id SET DEFAULT nextval('maasserver_staticipaddress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticroute ALTER COLUMN id SET DEFAULT nextval('maasserver_staticroute_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_subnet ALTER COLUMN id SET DEFAULT nextval('maasserver_subnet_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_tag ALTER COLUMN id SET DEFAULT nextval('maasserver_tag_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_template ALTER COLUMN id SET DEFAULT nextval('maasserver_template_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_userprofile ALTER COLUMN id SET DEFAULT nextval('maasserver_userprofile_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_versionedtextfile ALTER COLUMN id SET DEFAULT nextval('maasserver_versionedtextfile_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan ALTER COLUMN id SET DEFAULT nextval('maasserver_vlan_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_zone ALTER COLUMN id SET DEFAULT nextval('maasserver_zone_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_commissioningscript ALTER COLUMN id SET DEFAULT nextval('metadataserver_commissioningscript_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey ALTER COLUMN id SET DEFAULT nextval('metadataserver_nodekey_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_noderesult ALTER COLUMN id SET DEFAULT nextval('metadataserver_noderesult_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodeuserdata ALTER COLUMN id SET DEFAULT nextval('metadataserver_nodeuserdata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_consumer ALTER COLUMN id SET DEFAULT nextval('piston3_consumer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_nonce ALTER COLUMN id SET DEFAULT nextval('piston3_nonce_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_token ALTER COLUMN id SET DEFAULT nextval('piston3_token_id_seq'::regclass);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY auth_group (id, name) FROM stdin;
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('auth_group_id_seq', 1, false);


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('auth_group_permissions_id_seq', 1, false);


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add permission	1	add_permission
2	Can change permission	1	change_permission
3	Can delete permission	1	delete_permission
4	Can add group	2	add_group
5	Can change group	2	change_group
6	Can delete group	2	delete_group
7	Can add user	3	add_user
8	Can change user	3	change_user
9	Can delete user	3	delete_user
10	Can add content type	4	add_contenttype
11	Can change content type	4	change_contenttype
12	Can delete content type	4	delete_contenttype
13	Can add session	5	add_session
14	Can change session	5	change_session
15	Can delete session	5	delete_session
16	Can add site	6	add_site
17	Can change site	6	change_site
18	Can delete site	6	delete_site
19	Can add block device	7	add_blockdevice
20	Can change block device	7	change_blockdevice
21	Can delete block device	7	delete_blockdevice
22	Can add VersionedTextFile	8	add_versionedtextfile
23	Can change VersionedTextFile	8	change_versionedtextfile
24	Can delete VersionedTextFile	8	delete_versionedtextfile
25	Can add config	9	add_config
26	Can change config	9	change_config
27	Can delete config	9	delete_config
28	Can add Domain	10	add_domain
29	Can change Domain	10	change_domain
30	Can delete Domain	10	delete_domain
31	Can add static route	11	add_staticroute
32	Can change static route	11	change_staticroute
33	Can delete static route	11	delete_staticroute
34	Can add subnet	12	add_subnet
35	Can change subnet	12	change_subnet
36	Can delete subnet	12	delete_subnet
37	Can add Static IP Address	13	add_staticipaddress
38	Can change Static IP Address	13	change_staticipaddress
39	Can delete Static IP Address	13	delete_staticipaddress
40	Can add bmc	14	add_bmc
41	Can change bmc	14	change_bmc
42	Can delete bmc	14	delete_bmc
43	Can add bmc routable rack controller relationship	15	add_bmcroutablerackcontrollerrelationship
44	Can change bmc routable rack controller relationship	15	change_bmcroutablerackcontrollerrelationship
45	Can delete bmc routable rack controller relationship	15	delete_bmcroutablerackcontrollerrelationship
46	Can add boot source	16	add_bootsource
47	Can change boot source	16	change_bootsource
48	Can delete boot source	16	delete_bootsource
49	Can add boot source cache	17	add_bootsourcecache
50	Can change boot source cache	17	change_bootsourcecache
51	Can delete boot source cache	17	delete_bootsourcecache
52	Can add boot resource	18	add_bootresource
53	Can change boot resource	18	change_bootresource
54	Can delete boot resource	18	delete_bootresource
55	Can add boot resource set	19	add_bootresourceset
56	Can change boot resource set	19	change_bootresourceset
57	Can delete boot resource set	19	delete_bootresourceset
58	Can add large file	20	add_largefile
59	Can change large file	20	change_largefile
60	Can delete large file	20	delete_largefile
61	Can add boot resource file	21	add_bootresourcefile
62	Can change boot resource file	21	change_bootresourcefile
63	Can delete boot resource file	21	delete_bootresourcefile
64	Can add boot source selection	22	add_bootsourceselection
65	Can change boot source selection	22	change_bootsourceselection
66	Can delete boot source selection	22	delete_bootsourceselection
67	Can add cache set	23	add_cacheset
68	Can change cache set	23	change_cacheset
69	Can delete cache set	23	delete_cacheset
70	Can add Interface	24	add_interface
71	Can change Interface	24	change_interface
72	Can delete Interface	24	delete_interface
73	Can add interface relationship	25	add_interfacerelationship
74	Can change interface relationship	25	change_interfacerelationship
75	Can delete interface relationship	25	delete_interfacerelationship
76	Can add Physical interface	24	add_physicalinterface
77	Can change Physical interface	24	change_physicalinterface
78	Can delete Physical interface	24	delete_physicalinterface
79	Can add child interface	24	add_childinterface
80	Can change child interface	24	change_childinterface
81	Can delete child interface	24	delete_childinterface
82	Can add Bridge	24	add_bridgeinterface
83	Can change Bridge	24	change_bridgeinterface
84	Can delete Bridge	24	delete_bridgeinterface
85	Can add Bond	24	add_bondinterface
86	Can change Bond	24	change_bondinterface
87	Can delete Bond	24	delete_bondinterface
88	Can add VLAN interface	24	add_vlaninterface
89	Can change VLAN interface	24	change_vlaninterface
90	Can delete VLAN interface	24	delete_vlaninterface
91	Can add Unknown interface	24	add_unknowninterface
92	Can change Unknown interface	24	change_unknowninterface
93	Can delete Unknown interface	24	delete_unknowninterface
94	Can add Fabric	26	add_fabric
95	Can change Fabric	26	change_fabric
96	Can delete Fabric	26	delete_fabric
97	Can add filesystem group	27	add_filesystemgroup
98	Can change filesystem group	27	change_filesystemgroup
99	Can delete filesystem group	27	delete_filesystemgroup
100	Can add volume group	27	add_volumegroup
101	Can change volume group	27	change_volumegroup
102	Can delete volume group	27	delete_volumegroup
103	Can add raid	27	add_raid
104	Can change raid	27	change_raid
105	Can delete raid	27	delete_raid
106	Can add bcache	27	add_bcache
107	Can change bcache	27	change_bcache
108	Can delete bcache	27	delete_bcache
109	Can add partition	28	add_partition
110	Can change partition	28	change_partition
111	Can delete partition	28	delete_partition
112	Can add filesystem	29	add_filesystem
113	Can change filesystem	29	change_filesystem
114	Can delete filesystem	29	delete_filesystem
115	Can add license key	30	add_licensekey
116	Can change license key	30	change_licensekey
117	Can delete license key	30	delete_licensekey
118	Can add owner data	31	add_ownerdata
119	Can change owner data	31	change_ownerdata
120	Can delete owner data	31	delete_ownerdata
121	Can add partition table	32	add_partitiontable
122	Can change partition table	32	change_partitiontable
123	Can delete partition table	32	delete_partitiontable
124	Can add physical block device	33	add_physicalblockdevice
125	Can change physical block device	33	change_physicalblockdevice
126	Can delete physical block device	33	delete_physicalblockdevice
127	Can add service	34	add_service
128	Can change service	34	change_service
129	Can delete service	34	delete_service
130	Can add Space	35	add_space
131	Can change Space	35	change_space
132	Can delete Space	35	delete_space
133	Can add tag	36	add_tag
134	Can change tag	36	change_tag
135	Can delete tag	36	delete_tag
136	Can add VLAN	37	add_vlan
137	Can change VLAN	37	change_vlan
138	Can delete VLAN	37	delete_vlan
139	Can add Physical zone	38	add_zone
140	Can change Physical zone	38	change_zone
141	Can delete Physical zone	38	delete_zone
142	Can add node	39	add_node
143	Can change node	39	change_node
144	Can delete node	39	delete_node
145	Can add machine	39	add_machine
146	Can change machine	39	change_machine
147	Can delete machine	39	delete_machine
148	Can add controller	39	add_controller
149	Can change controller	39	change_controller
150	Can delete controller	39	delete_controller
151	Can add rack controller	39	add_rackcontroller
152	Can change rack controller	39	change_rackcontroller
153	Can delete rack controller	39	delete_rackcontroller
154	Can add region controller	39	add_regioncontroller
155	Can change region controller	39	change_regioncontroller
156	Can delete region controller	39	delete_regioncontroller
157	Can add device	39	add_device
158	Can change device	39	change_device
159	Can delete device	39	delete_device
160	Can add chassis	39	add_chassis
161	Can change chassis	39	change_chassis
162	Can delete chassis	39	delete_chassis
163	Can add storage	39	add_storage
164	Can change storage	39	change_storage
165	Can delete storage	39	delete_storage
166	Can add node group to rack controller	40	add_nodegrouptorackcontroller
167	Can change node group to rack controller	40	change_nodegrouptorackcontroller
168	Can delete node group to rack controller	40	delete_nodegrouptorackcontroller
169	Can add chassis hints	41	add_chassishints
170	Can change chassis hints	41	change_chassishints
171	Can delete chassis hints	41	delete_chassishints
172	Can add component error	42	add_componenterror
173	Can change component error	42	change_componenterror
174	Can delete component error	42	delete_componenterror
175	Can add dhcp snippet	43	add_dhcpsnippet
176	Can change dhcp snippet	43	change_dhcpsnippet
177	Can delete dhcp snippet	43	delete_dhcpsnippet
178	Can add Discovery	44	add_discovery
179	Can change Discovery	44	change_discovery
180	Can delete Discovery	44	delete_discovery
181	Can add DNSResource	45	add_dnsresource
182	Can change DNSResource	45	change_dnsresource
183	Can delete DNSResource	45	delete_dnsresource
184	Can add DNSData	46	add_dnsdata
185	Can change DNSData	46	change_dnsdata
186	Can delete DNSData	46	delete_dnsdata
187	Can add dns publication	47	add_dnspublication
188	Can change dns publication	47	change_dnspublication
189	Can delete dns publication	47	delete_dnspublication
190	Can add Event type	48	add_eventtype
191	Can change Event type	48	change_eventtype
192	Can delete Event type	48	delete_eventtype
193	Can add Event record	49	add_event
194	Can change Event record	49	change_event
195	Can delete Event record	49	delete_event
196	Can add Fan Network	50	add_fannetwork
197	Can change Fan Network	50	change_fannetwork
198	Can delete Fan Network	50	delete_fannetwork
199	Can add file storage	51	add_filestorage
200	Can change file storage	51	change_filestorage
201	Can delete file storage	51	delete_filestorage
202	Can add ip range	52	add_iprange
203	Can change ip range	52	change_iprange
204	Can delete ip range	52	delete_iprange
205	Can add Key Source	53	add_keysource
206	Can change Key Source	53	change_keysource
207	Can delete Key Source	53	delete_keysource
208	Can add mDNS binding	54	add_mdns
209	Can change mDNS binding	54	change_mdns
210	Can delete mDNS binding	54	delete_mdns
211	Can add Neighbour	55	add_neighbour
212	Can change Neighbour	55	change_neighbour
213	Can delete Neighbour	55	delete_neighbour
214	Can add package repository	56	add_packagerepository
215	Can change package repository	56	change_packagerepository
216	Can delete package repository	56	delete_packagerepository
217	Can add Reverse-DNS entry	57	add_rdns
218	Can change Reverse-DNS entry	57	change_rdns
219	Can delete Reverse-DNS entry	57	delete_rdns
220	Can add region controller process	58	add_regioncontrollerprocess
221	Can change region controller process	58	change_regioncontrollerprocess
222	Can delete region controller process	58	delete_regioncontrollerprocess
223	Can add region controller process endpoint	59	add_regioncontrollerprocessendpoint
224	Can change region controller process endpoint	59	change_regioncontrollerprocessendpoint
225	Can delete region controller process endpoint	59	delete_regioncontrollerprocessendpoint
226	Can add region rack rpc connection	60	add_regionrackrpcconnection
227	Can change region rack rpc connection	60	change_regionrackrpcconnection
228	Can delete region rack rpc connection	60	delete_regionrackrpcconnection
229	Can add SSH key	61	add_sshkey
230	Can change SSH key	61	change_sshkey
231	Can delete SSH key	61	delete_sshkey
232	Can add SSL key	62	add_sslkey
233	Can change SSL key	62	change_sslkey
234	Can delete SSL key	62	delete_sslkey
235	Can add Template	63	add_template
236	Can change Template	63	change_template
237	Can delete Template	63	delete_template
238	Can add user profile	64	add_userprofile
239	Can change user profile	64	change_userprofile
240	Can delete user profile	64	delete_userprofile
241	Can add virtual block device	65	add_virtualblockdevice
242	Can change virtual block device	65	change_virtualblockdevice
243	Can delete virtual block device	65	delete_virtualblockdevice
244	Can add node result	82	add_noderesult
245	Can change node result	82	change_noderesult
246	Can delete node result	82	delete_noderesult
247	Can add commissioning script	83	add_commissioningscript
248	Can change commissioning script	83	change_commissioningscript
249	Can delete commissioning script	83	delete_commissioningscript
250	Can add node key	84	add_nodekey
251	Can change node key	84	change_nodekey
252	Can delete node key	84	delete_nodekey
253	Can add node user data	85	add_nodeuserdata
254	Can change node user data	85	change_nodeuserdata
255	Can delete node user data	85	delete_nodeuserdata
256	Can add nonce	86	add_nonce
257	Can change nonce	86	change_nonce
258	Can delete nonce	86	delete_nonce
259	Can add consumer	87	add_consumer
260	Can change consumer	87	change_consumer
261	Can delete consumer	87	delete_consumer
262	Can add token	88	add_token
263	Can change token	88	change_token
264	Can delete token	88	delete_token
265	Can add notification	89	add_notification
266	Can change notification	89	change_notification
267	Can delete notification	89	delete_notification
\.


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('auth_permission_id_seq', 267, true);


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('auth_user_id_seq', 1, false);


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('auth_user_user_permissions_id_seq', 1, false);


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY django_content_type (id, app_label, model) FROM stdin;
1	auth	permission
2	auth	group
3	auth	user
4	contenttypes	contenttype
5	sessions	session
6	sites	site
7	maasserver	blockdevice
8	maasserver	versionedtextfile
9	maasserver	config
10	maasserver	domain
11	maasserver	staticroute
12	maasserver	subnet
13	maasserver	staticipaddress
14	maasserver	bmc
15	maasserver	bmcroutablerackcontrollerrelationship
16	maasserver	bootsource
17	maasserver	bootsourcecache
18	maasserver	bootresource
19	maasserver	bootresourceset
20	maasserver	largefile
21	maasserver	bootresourcefile
22	maasserver	bootsourceselection
23	maasserver	cacheset
24	maasserver	interface
25	maasserver	interfacerelationship
26	maasserver	fabric
27	maasserver	filesystemgroup
28	maasserver	partition
29	maasserver	filesystem
30	maasserver	licensekey
31	maasserver	ownerdata
32	maasserver	partitiontable
33	maasserver	physicalblockdevice
34	maasserver	service
35	maasserver	space
36	maasserver	tag
37	maasserver	vlan
38	maasserver	zone
39	maasserver	node
40	maasserver	nodegrouptorackcontroller
41	maasserver	chassishints
42	maasserver	componenterror
43	maasserver	dhcpsnippet
44	maasserver	discovery
45	maasserver	dnsresource
46	maasserver	dnsdata
47	maasserver	dnspublication
48	maasserver	eventtype
49	maasserver	event
50	maasserver	fannetwork
51	maasserver	filestorage
52	maasserver	iprange
53	maasserver	keysource
54	maasserver	mdns
55	maasserver	neighbour
56	maasserver	packagerepository
57	maasserver	rdns
58	maasserver	regioncontrollerprocess
59	maasserver	regioncontrollerprocessendpoint
60	maasserver	regionrackrpcconnection
61	maasserver	sshkey
62	maasserver	sslkey
63	maasserver	template
64	maasserver	userprofile
65	maasserver	virtualblockdevice
66	maasserver	bridgeinterface
67	maasserver	machine
68	maasserver	bcache
69	maasserver	unknowninterface
70	maasserver	regioncontroller
71	maasserver	childinterface
72	maasserver	vlaninterface
73	maasserver	bondinterface
74	maasserver	storage
75	maasserver	controller
76	maasserver	physicalinterface
77	maasserver	chassis
78	maasserver	device
79	maasserver	raid
80	maasserver	rackcontroller
81	maasserver	volumegroup
82	metadataserver	noderesult
83	metadataserver	commissioningscript
84	metadataserver	nodekey
85	metadataserver	nodeuserdata
86	piston3	nonce
87	piston3	consumer
88	piston3	token
89	maasserver	notification
\.


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('django_content_type_id_seq', 89, true);


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2016-12-22 16:12:48.780764+00
2	auth	0001_initial	2016-12-22 16:12:48.824869+00
3	auth	0002_auto_20151119_1629	2016-12-22 16:12:48.915292+00
4	contenttypes	0002_remove_content_type_name	2016-12-22 16:12:48.951044+00
5	piston3	0001_initial	2016-12-22 16:12:48.987399+00
6	maasserver	0001_initial	2016-12-22 16:12:50.849727+00
7	maasserver	0002_remove_candidate_name_model	2016-12-22 16:12:50.855004+00
8	maasserver	0003_add_node_type_to_node	2016-12-22 16:12:50.910847+00
9	maasserver	0004_migrate_installable_to_node_type	2016-12-22 16:12:50.916565+00
10	maasserver	0005_delete_installable_from_node	2016-12-22 16:12:50.966553+00
11	maasserver	0006_add_lease_time_to_staticipaddress	2016-12-22 16:12:51.018294+00
12	maasserver	0007_create_node_proxy_models	2016-12-22 16:12:51.0281+00
13	maasserver	0008_use_new_arrayfield	2016-12-22 16:12:51.237666+00
14	maasserver	0009_remove_routers_field_from_node	2016-12-22 16:12:51.289082+00
15	maasserver	0010_add_dns_models	2016-12-22 16:12:51.434248+00
16	maasserver	0011_domain_data	2016-12-22 16:12:51.447946+00
17	maasserver	0012_drop_dns_fields	2016-12-22 16:12:51.690786+00
18	maasserver	0013_remove_boot_type_from_node	2016-12-22 16:12:51.751756+00
19	maasserver	0014_add_region_models	2016-12-22 16:12:52.512657+00
20	maasserver	0015_add_bmc_model	2016-12-22 16:12:52.746889+00
21	maasserver	0016_migrate_power_data_node_to_bmc	2016-12-22 16:12:52.754716+00
22	maasserver	0017_remove_node_power_type	2016-12-22 16:12:52.814375+00
23	maasserver	0018_add_dnsdata	2016-12-22 16:12:52.989261+00
24	maasserver	0019_add_iprange	2016-12-22 16:12:53.053695+00
25	maasserver	0020_nodegroup_to_rackcontroller	2016-12-22 16:12:53.120731+00
26	maasserver	0021_nodegroupinterface_to_iprange	2016-12-22 16:12:53.126589+00
27	maasserver	0022_extract_ip_for_bmcs	2016-12-22 16:12:53.13167+00
28	maasserver	0023_add_ttl_field	2016-12-22 16:12:53.62911+00
29	maasserver	0024_remove_nodegroupinterface	2016-12-22 16:12:55.232612+00
30	maasserver	0025_create_node_system_id_sequence	2016-12-22 16:12:55.239278+00
31	maasserver	0026_create_zone_serial_sequence	2016-12-22 16:12:55.244321+00
32	maasserver	0027_replace_static_range_with_admin_reserved_ranges	2016-12-22 16:12:55.249333+00
33	maasserver	0028_update_default_vlan_on_interface_and_subnet	2016-12-22 16:12:55.416936+00
34	maasserver	0029_add_rdns_mode	2016-12-22 16:12:55.478977+00
35	maasserver	0030_drop_all_old_funcs	2016-12-22 16:12:55.485621+00
36	maasserver	0031_add_region_rack_rpc_conn_model	2016-12-22 16:12:55.666753+00
37	maasserver	0032_loosen_vlan	2016-12-22 16:12:55.823966+00
38	maasserver	0033_iprange_minor_changes	2016-12-22 16:12:56.056501+00
39	maasserver	0034_rename_mount_params_as_mount_options	2016-12-22 16:12:56.11337+00
40	maasserver	0035_convert_ether_wake_to_manual_power_type	2016-12-22 16:12:56.117943+00
41	maasserver	0036_add_service_model	2016-12-22 16:12:56.234182+00
42	maasserver	0037_node_last_image_sync	2016-12-22 16:12:56.294003+00
43	maasserver	0038_filesystem_ramfs_tmpfs_support	2016-12-22 16:12:56.411164+00
44	maasserver	0039_create_template_and_versionedtextfile_models	2016-12-22 16:12:56.439634+00
45	maasserver	0040_fix_id_seq	2016-12-22 16:12:56.444251+00
46	maasserver	0041_change_bmc_on_delete_to_set_null	2016-12-22 16:12:56.515982+00
47	maasserver	0042_add_routable_rack_controllers_to_bmc	2016-12-22 16:12:56.635996+00
48	maasserver	0043_dhcpsnippet	2016-12-22 16:12:57.043898+00
49	maasserver	0044_remove_di_bootresourcefiles	2016-12-22 16:12:57.057914+00
50	maasserver	0045_add_node_to_filesystem	2016-12-22 16:12:57.142462+00
51	maasserver	0046_add_bridge_interface_type	2016-12-22 16:12:57.21783+00
52	maasserver	0047_fix_spelling_of_degraded	2016-12-22 16:12:57.286728+00
53	maasserver	0048_add_subnet_allow_proxy	2016-12-22 16:12:57.354181+00
54	maasserver	0049_add_external_dhcp_present_to_vlan	2016-12-22 16:12:57.580516+00
55	maasserver	0050_modify_external_dhcp_on_vlan	2016-12-22 16:12:57.93082+00
56	maasserver	0051_space_fabric_unique	2016-12-22 16:12:58.130705+00
57	maasserver	0052_add_codename_title_eol_to_bootresourcecache	2016-12-22 16:12:58.15942+00
58	maasserver	0053_add_ownerdata_model	2016-12-22 16:12:58.30316+00
59	maasserver	0054_controller	2016-12-22 16:12:58.310138+00
60	maasserver	0055_dns_publications	2016-12-22 16:12:58.319825+00
61	maasserver	0056_zone_serial_ownership	2016-12-22 16:12:58.328533+00
62	maasserver	0057_initial_dns_publication	2016-12-22 16:12:58.334737+00
63	maasserver	0058_bigger_integer_for_dns_publication_serial	2016-12-22 16:12:58.343278+00
64	maasserver	0056_add_description_to_fabric_and_space	2016-12-22 16:12:58.86343+00
65	maasserver	0057_merge	2016-12-22 16:12:58.864997+00
66	maasserver	0059_merge	2016-12-22 16:12:58.866684+00
67	maasserver	0060_amt_remove_mac_address	2016-12-22 16:12:58.879393+00
68	maasserver	0061_maas_nodegroup_worker_to_maas	2016-12-22 16:12:58.889271+00
69	maasserver	0062_fix_bootsource_daily_label	2016-12-22 16:12:58.898523+00
70	maasserver	0063_remove_orphaned_bmcs_and_ips	2016-12-22 16:12:58.908506+00
71	maasserver	0064_remove_unneeded_event_triggers	2016-12-22 16:12:58.916354+00
72	maasserver	0065_larger_osystem_and_distro_series	2016-12-22 16:12:59.103521+00
73	maasserver	0066_allow_squashfs	2016-12-22 16:12:59.115008+00
74	maasserver	0067_add_size_to_largefile	2016-12-22 16:12:59.488399+00
75	maasserver	0068_drop_node_system_id_sequence	2016-12-22 16:12:59.494901+00
76	maasserver	0069_add_previous_node_status_to_node	2016-12-22 16:12:59.581833+00
77	maasserver	0070_allow_null_vlan_on_interface	2016-12-22 16:12:59.685848+00
78	maasserver	0071_ntp_server_to_ntp_servers	2016-12-22 16:12:59.69359+00
79	maasserver	0072_packagerepository	2016-12-22 16:12:59.706554+00
80	maasserver	0073_migrate_package_repositories	2016-12-22 16:12:59.719135+00
81	maasserver	0072_update_status_and_previous_status	2016-12-22 16:12:59.887536+00
82	maasserver	0074_merge	2016-12-22 16:12:59.889163+00
83	maasserver	0075_modify_packagerepository	2016-12-22 16:12:59.929104+00
84	maasserver	0076_interface_discovery_rescue_mode	2016-12-22 16:13:00.717049+00
85	maasserver	0077_static_routes	2016-12-22 16:13:00.870822+00
86	maasserver	0078_remove_packagerepository_description	2016-12-22 16:13:00.879306+00
87	maasserver	0079_add_keysource_model	2016-12-22 16:13:01.073743+00
88	maasserver	0080_change_packagerepository_url_type	2016-12-22 16:13:01.082108+00
89	maasserver	0081_allow_larger_bootsourcecache_fields	2016-12-22 16:13:01.128426+00
90	maasserver	0082_add_kflavor	2016-12-22 16:13:01.159138+00
91	maasserver	0083_device_discovery	2016-12-22 16:13:01.239036+00
92	maasserver	0084_add_default_user_to_node_model	2016-12-22 16:13:01.325484+00
93	maasserver	0085_no_intro_on_upgrade	2016-12-22 16:13:01.331129+00
94	maasserver	0086_remove_powerpc_from_ports_arches	2016-12-22 16:13:01.354479+00
95	maasserver	0087_add_completed_intro_to_userprofile	2016-12-22 16:13:01.43204+00
96	maasserver	0088_remove_node_disable_ipv4	2016-12-22 16:13:01.860411+00
97	maasserver	0089_active_discovery	2016-12-22 16:13:02.093931+00
98	maasserver	0090_bootloaders	2016-12-22 16:13:02.156343+00
99	maasserver	0091_v2_to_v3	2016-12-22 16:13:02.162578+00
100	maasserver	0092_rolling	2016-12-22 16:13:02.175434+00
101	maasserver	0093_add_rdns_model	2016-12-22 16:13:02.354338+00
102	maasserver	0094_add_unmanaged_subnets	2016-12-22 16:13:02.441205+00
103	maasserver	0095_vlan_relay_vlan	2016-12-22 16:13:02.530022+00
104	maasserver	0096_set_default_vlan_field	2016-12-22 16:13:02.712764+00
105	maasserver	0097_node_chassis_storage_hints	2016-12-22 16:13:03.353999+00
106	maasserver	0098_add_space_to_vlan	2016-12-22 16:13:03.44168+00
107	maasserver	0099_set_default_vlan_field	2016-12-22 16:13:03.559492+00
108	maasserver	0100_migrate_spaces_from_subnet_to_vlan	2016-12-22 16:13:03.56569+00
109	maasserver	0101_filesystem_btrfs_support	2016-12-22 16:13:03.651028+00
110	metadataserver	0001_initial	2016-12-22 16:13:04.035605+00
111	piston3	0002_auto_20151209_1652	2016-12-22 16:13:04.133972+00
112	sessions	0001_initial	2016-12-22 16:13:04.143715+00
113	sites	0001_initial	2016-12-22 16:13:04.152877+00
114	maasserver	0102_remove_space_from_subnet	2017-01-05 10:58:03.75103+00
115	maasserver	0103_notifications	2017-01-05 10:58:03.851766+00
\.


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('django_migrations_id_seq', 115, true);


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- Data for Name: django_site; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY django_site (id, domain, name) FROM stdin;
1	example.com	example.com
\.


--
-- Name: django_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('django_site_id_seq', 1, true);


--
-- Data for Name: maasserver_blockdevice; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_blockdevice (id, created, updated, name, id_path, size, block_size, tags, node_id) FROM stdin;
\.


--
-- Name: maasserver_blockdevice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_blockdevice_id_seq', 1, false);


--
-- Data for Name: maasserver_bmc; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bmc (id, created, updated, power_type, power_parameters, ip_address_id) FROM stdin;
\.


--
-- Name: maasserver_bmc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bmc_id_seq', 1, false);


--
-- Data for Name: maasserver_bmcroutablerackcontrollerrelationship; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bmcroutablerackcontrollerrelationship (id, created, updated, routable, bmc_id, rack_controller_id) FROM stdin;
\.


--
-- Name: maasserver_bmcroutablerackcontrollerrelationship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bmcroutablerackcontrollerrelationship_id_seq', 1, false);


--
-- Data for Name: maasserver_bootresource; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bootresource (id, created, updated, rtype, name, architecture, extra, kflavor, bootloader_type, rolling) FROM stdin;
\.


--
-- Name: maasserver_bootresource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bootresource_id_seq', 1, false);


--
-- Data for Name: maasserver_bootresourcefile; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bootresourcefile (id, created, updated, filename, filetype, extra, largefile_id, resource_set_id) FROM stdin;
\.


--
-- Name: maasserver_bootresourcefile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bootresourcefile_id_seq', 1, false);


--
-- Data for Name: maasserver_bootresourceset; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bootresourceset (id, created, updated, version, label, resource_id) FROM stdin;
\.


--
-- Name: maasserver_bootresourceset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bootresourceset_id_seq', 1, false);


--
-- Data for Name: maasserver_bootsource; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bootsource (id, created, updated, url, keyring_filename, keyring_data) FROM stdin;
\.


--
-- Name: maasserver_bootsource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bootsource_id_seq', 1, false);


--
-- Data for Name: maasserver_bootsourcecache; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bootsourcecache (id, created, updated, os, arch, subarch, release, label, boot_source_id, release_codename, release_title, support_eol, kflavor, bootloader_type) FROM stdin;
\.


--
-- Name: maasserver_bootsourcecache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bootsourcecache_id_seq', 1, false);


--
-- Data for Name: maasserver_bootsourceselection; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_bootsourceselection (id, created, updated, os, release, arches, subarches, labels, boot_source_id) FROM stdin;
\.


--
-- Name: maasserver_bootsourceselection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_bootsourceselection_id_seq', 1, false);


--
-- Data for Name: maasserver_cacheset; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_cacheset (id, created, updated) FROM stdin;
\.


--
-- Name: maasserver_cacheset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_cacheset_id_seq', 1, false);


--
-- Data for Name: maasserver_chassishints; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_chassishints (id, cores, memory, local_storage, chassis_id) FROM stdin;
\.


--
-- Name: maasserver_chassishints_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_chassishints_id_seq', 1, false);


--
-- Data for Name: maasserver_componenterror; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_componenterror (id, created, updated, component, error) FROM stdin;
\.


--
-- Name: maasserver_componenterror_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_componenterror_id_seq', 1, false);


--
-- Data for Name: maasserver_config; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_config (id, name, value) FROM stdin;
\.


--
-- Name: maasserver_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_config_id_seq', 1, false);


--
-- Data for Name: maasserver_dhcpsnippet; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_dhcpsnippet (id, created, updated, name, description, enabled, node_id, subnet_id, value_id) FROM stdin;
\.


--
-- Name: maasserver_dhcpsnippet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_dhcpsnippet_id_seq', 1, false);


--
-- Data for Name: maasserver_dnsdata; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_dnsdata (id, created, updated, rrtype, rrdata, dnsresource_id, ttl) FROM stdin;
\.


--
-- Name: maasserver_dnsdata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_dnsdata_id_seq', 1, false);


--
-- Data for Name: maasserver_dnspublication; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_dnspublication (id, serial, created, source) FROM stdin;
1	1	2016-12-22 16:12:58.333075+00	Initial publication
\.


--
-- Name: maasserver_dnspublication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_dnspublication_id_seq', 1, true);


--
-- Data for Name: maasserver_dnsresource; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_dnsresource (id, created, updated, name, domain_id, address_ttl) FROM stdin;
\.


--
-- Name: maasserver_dnsresource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_dnsresource_id_seq', 1, false);


--
-- Data for Name: maasserver_dnsresource_ip_addresses; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_dnsresource_ip_addresses (id, dnsresource_id, staticipaddress_id) FROM stdin;
\.


--
-- Name: maasserver_dnsresource_ip_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_dnsresource_ip_addresses_id_seq', 1, false);


--
-- Data for Name: maasserver_domain; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_domain (id, created, updated, name, authoritative, ttl) FROM stdin;
0	2016-12-22 16:12:51.437798+00	2016-12-22 16:12:51.437798+00	maas	t	\N
\.


--
-- Name: maasserver_domain_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_domain_id_seq', 1, false);


--
-- Data for Name: maasserver_event; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_event (id, created, updated, action, description, node_id, type_id) FROM stdin;
\.


--
-- Name: maasserver_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_event_id_seq', 1, false);


--
-- Data for Name: maasserver_eventtype; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_eventtype (id, created, updated, name, description, level) FROM stdin;
\.


--
-- Name: maasserver_eventtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_eventtype_id_seq', 1, false);


--
-- Data for Name: maasserver_fabric; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_fabric (id, created, updated, name, class_type, description) FROM stdin;
0	2016-12-22 16:13:03.551368+00	2016-12-22 16:13:03.523655+00	fabric-0	\N	
\.


--
-- Name: maasserver_fabric_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_fabric_id_seq', 1, false);


--
-- Data for Name: maasserver_fannetwork; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_fannetwork (id, created, updated, name, "overlay", underlay, dhcp, host_reserve, bridge, off) FROM stdin;
\.


--
-- Name: maasserver_fannetwork_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_fannetwork_id_seq', 1, false);


--
-- Data for Name: maasserver_filestorage; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_filestorage (id, filename, content, key, owner_id) FROM stdin;
\.


--
-- Name: maasserver_filestorage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_filestorage_id_seq', 1, false);


--
-- Data for Name: maasserver_filesystem; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_filesystem (id, created, updated, uuid, fstype, label, create_params, mount_point, mount_options, acquired, block_device_id, cache_set_id, filesystem_group_id, partition_id, node_id) FROM stdin;
\.


--
-- Name: maasserver_filesystem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_filesystem_id_seq', 1, false);


--
-- Data for Name: maasserver_filesystemgroup; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_filesystemgroup (id, created, updated, uuid, group_type, name, create_params, cache_mode, cache_set_id) FROM stdin;
\.


--
-- Name: maasserver_filesystemgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_filesystemgroup_id_seq', 1, false);


--
-- Data for Name: maasserver_interface; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_interface (id, created, updated, name, type, mac_address, ipv4_params, ipv6_params, params, tags, enabled, node_id, vlan_id, acquired, mdns_discovery_state, neighbour_discovery_state) FROM stdin;
\.


--
-- Name: maasserver_interface_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_interface_id_seq', 1, false);


--
-- Data for Name: maasserver_interface_ip_addresses; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_interface_ip_addresses (id, interface_id, staticipaddress_id) FROM stdin;
\.


--
-- Name: maasserver_interface_ip_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_interface_ip_addresses_id_seq', 1, false);


--
-- Data for Name: maasserver_interfacerelationship; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_interfacerelationship (id, created, updated, child_id, parent_id) FROM stdin;
\.


--
-- Name: maasserver_interfacerelationship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_interfacerelationship_id_seq', 1, false);


--
-- Data for Name: maasserver_iprange; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_iprange (id, created, updated, type, start_ip, end_ip, comment, subnet_id, user_id) FROM stdin;
\.


--
-- Name: maasserver_iprange_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_iprange_id_seq', 1, false);


--
-- Data for Name: maasserver_keysource; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_keysource (id, created, updated, protocol, auth_id, auto_update) FROM stdin;
\.


--
-- Name: maasserver_keysource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_keysource_id_seq', 1, false);


--
-- Data for Name: maasserver_largefile; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_largefile (id, created, updated, sha256, total_size, content, size) FROM stdin;
\.


--
-- Name: maasserver_largefile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_largefile_id_seq', 1, false);


--
-- Data for Name: maasserver_licensekey; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_licensekey (id, created, updated, osystem, distro_series, license_key) FROM stdin;
\.


--
-- Name: maasserver_licensekey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_licensekey_id_seq', 1, false);


--
-- Data for Name: maasserver_mdns; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_mdns (id, created, updated, ip, hostname, count, interface_id) FROM stdin;
\.


--
-- Name: maasserver_mdns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_mdns_id_seq', 1, false);


--
-- Data for Name: maasserver_neighbour; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_neighbour (id, created, updated, ip, "time", vid, count, mac_address, interface_id) FROM stdin;
\.


--
-- Name: maasserver_neighbour_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_neighbour_id_seq', 1, false);


--
-- Data for Name: maasserver_node; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_node (id, created, updated, system_id, hostname, status, bios_boot_method, osystem, distro_series, architecture, min_hwe_kernel, hwe_kernel, agent_name, error_description, cpu_count, memory, swap_size, instance_power_parameters, power_state, power_state_updated, error, netboot, license_key, boot_cluster_ip, enable_ssh, skip_networking, skip_storage, boot_interface_id, gateway_link_ipv4_id, gateway_link_ipv6_id, owner_id, parent_id, token_id, zone_id, boot_disk_id, node_type, domain_id, dns_process_id, bmc_id, address_ttl, status_expires, power_state_queried, url, managing_process_id, last_image_sync, previous_status, default_user, cpu_speed, dynamic) FROM stdin;
\.


--
-- Name: maasserver_node_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_node_id_seq', 1, false);


--
-- Data for Name: maasserver_node_tags; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_node_tags (id, node_id, tag_id) FROM stdin;
\.


--
-- Name: maasserver_node_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_node_tags_id_seq', 1, false);


--
-- Data for Name: maasserver_nodegrouptorackcontroller; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_nodegrouptorackcontroller (id, uuid, subnet_id) FROM stdin;
\.


--
-- Name: maasserver_nodegrouptorackcontroller_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_nodegrouptorackcontroller_id_seq', 1, false);


--
-- Data for Name: maasserver_notification; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_notification (id, created, updated, ident, users, admins, message, context, user_id) FROM stdin;
\.


--
-- Name: maasserver_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_notification_id_seq', 1, false);


--
-- Data for Name: maasserver_ownerdata; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_ownerdata (id, key, value, node_id) FROM stdin;
\.


--
-- Name: maasserver_ownerdata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_ownerdata_id_seq', 1, false);


--
-- Data for Name: maasserver_packagerepository; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_packagerepository (id, created, updated, name, url, components, arches, key, "default", enabled, disabled_pockets, distributions) FROM stdin;
1	2016-12-22 16:12:59.712004+00	2016-12-22 16:12:59.712004+00	main_archive	http://archive.ubuntu.com/ubuntu	{}	{amd64,i386}		t	t	{}	{}
2	2016-12-22 16:12:59.712004+00	2016-12-22 16:12:59.712004+00	ports_archive	http://ports.ubuntu.com/ubuntu-ports	{}	{armhf,arm64,ppc64el}		t	t	{}	{}
\.


--
-- Name: maasserver_packagerepository_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_packagerepository_id_seq', 2, true);


--
-- Data for Name: maasserver_partition; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_partition (id, created, updated, uuid, size, bootable, partition_table_id) FROM stdin;
\.


--
-- Name: maasserver_partition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_partition_id_seq', 1, false);


--
-- Data for Name: maasserver_partitiontable; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_partitiontable (id, created, updated, table_type, block_device_id) FROM stdin;
\.


--
-- Name: maasserver_partitiontable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_partitiontable_id_seq', 1, false);


--
-- Data for Name: maasserver_physicalblockdevice; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_physicalblockdevice (blockdevice_ptr_id, model, serial) FROM stdin;
\.


--
-- Data for Name: maasserver_rdns; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_rdns (id, created, updated, ip, hostname, hostnames, observer_id) FROM stdin;
\.


--
-- Name: maasserver_rdns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_rdns_id_seq', 1, false);


--
-- Data for Name: maasserver_regioncontrollerprocess; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_regioncontrollerprocess (id, created, updated, pid, region_id) FROM stdin;
\.


--
-- Name: maasserver_regioncontrollerprocess_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_regioncontrollerprocess_id_seq', 1, false);


--
-- Data for Name: maasserver_regioncontrollerprocessendpoint; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_regioncontrollerprocessendpoint (id, created, updated, address, port, process_id) FROM stdin;
\.


--
-- Name: maasserver_regioncontrollerprocessendpoint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_regioncontrollerprocessendpoint_id_seq', 1, false);


--
-- Data for Name: maasserver_regionrackrpcconnection; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_regionrackrpcconnection (id, created, updated, endpoint_id, rack_controller_id) FROM stdin;
\.


--
-- Name: maasserver_regionrackrpcconnection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_regionrackrpcconnection_id_seq', 1, false);


--
-- Data for Name: maasserver_service; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_service (id, created, updated, name, status, status_info, node_id) FROM stdin;
\.


--
-- Name: maasserver_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_service_id_seq', 1, false);


--
-- Data for Name: maasserver_space; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_space (id, created, updated, name, description) FROM stdin;
\.


--
-- Name: maasserver_space_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_space_id_seq', 1, false);


--
-- Data for Name: maasserver_sshkey; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_sshkey (id, created, updated, key, user_id, keysource_id) FROM stdin;
\.


--
-- Name: maasserver_sshkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_sshkey_id_seq', 1, false);


--
-- Data for Name: maasserver_sslkey; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_sslkey (id, created, updated, key, user_id) FROM stdin;
\.


--
-- Name: maasserver_sslkey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_sslkey_id_seq', 1, false);


--
-- Data for Name: maasserver_staticipaddress; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_staticipaddress (id, created, updated, ip, alloc_type, subnet_id, user_id, lease_time) FROM stdin;
\.


--
-- Name: maasserver_staticipaddress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_staticipaddress_id_seq', 1, false);


--
-- Data for Name: maasserver_staticroute; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_staticroute (id, gateway_ip, metric, destination_id, source_id, created, updated) FROM stdin;
\.


--
-- Name: maasserver_staticroute_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_staticroute_id_seq', 1, false);


--
-- Data for Name: maasserver_subnet; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_subnet (id, created, updated, name, cidr, gateway_ip, dns_servers, vlan_id, rdns_mode, allow_proxy, description, active_discovery, managed) FROM stdin;
\.


--
-- Name: maasserver_subnet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_subnet_id_seq', 1, false);


--
-- Data for Name: maasserver_tag; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_tag (id, created, updated, name, definition, comment, kernel_opts) FROM stdin;
\.


--
-- Name: maasserver_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_tag_id_seq', 1, false);


--
-- Data for Name: maasserver_template; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_template (id, created, updated, filename, default_version_id, version_id) FROM stdin;
\.


--
-- Name: maasserver_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_template_id_seq', 1, false);


--
-- Data for Name: maasserver_userprofile; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_userprofile (id, user_id, completed_intro) FROM stdin;
\.


--
-- Name: maasserver_userprofile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_userprofile_id_seq', 1, false);


--
-- Data for Name: maasserver_versionedtextfile; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_versionedtextfile (id, created, updated, data, comment, previous_version_id) FROM stdin;
\.


--
-- Name: maasserver_versionedtextfile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_versionedtextfile_id_seq', 1, false);


--
-- Data for Name: maasserver_virtualblockdevice; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_virtualblockdevice (blockdevice_ptr_id, uuid, filesystem_group_id) FROM stdin;
\.


--
-- Data for Name: maasserver_vlan; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_vlan (id, created, updated, name, vid, mtu, fabric_id, dhcp_on, primary_rack_id, secondary_rack_id, external_dhcp, description, relay_vlan_id, space_id) FROM stdin;
5001	2016-12-22 16:13:03.523655+00	2016-12-22 16:13:03.523655+00	Default VLAN	0	1500	0	f	\N	\N	\N		\N	\N
\.


--
-- Name: maasserver_vlan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_vlan_id_seq', 5001, true);


--
-- Data for Name: maasserver_zone; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY maasserver_zone (id, created, updated, name, description) FROM stdin;
1	2016-12-22 16:12:49.588022+00	2016-12-22 16:12:49.588022+00	default	
\.


--
-- Name: maasserver_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_zone_id_seq', 1, true);


--
-- Name: maasserver_zone_serial_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('maasserver_zone_serial_seq', 3, true);


--
-- Data for Name: metadataserver_commissioningscript; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY metadataserver_commissioningscript (id, name, content) FROM stdin;
\.


--
-- Name: metadataserver_commissioningscript_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('metadataserver_commissioningscript_id_seq', 1, false);


--
-- Data for Name: metadataserver_nodekey; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY metadataserver_nodekey (id, key, node_id, token_id) FROM stdin;
\.


--
-- Name: metadataserver_nodekey_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('metadataserver_nodekey_id_seq', 1, false);


--
-- Data for Name: metadataserver_noderesult; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY metadataserver_noderesult (id, created, updated, script_result, result_type, name, data, node_id) FROM stdin;
\.


--
-- Name: metadataserver_noderesult_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('metadataserver_noderesult_id_seq', 1, false);


--
-- Data for Name: metadataserver_nodeuserdata; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY metadataserver_nodeuserdata (id, data, node_id) FROM stdin;
\.


--
-- Name: metadataserver_nodeuserdata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('metadataserver_nodeuserdata_id_seq', 1, false);


--
-- Data for Name: piston3_consumer; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY piston3_consumer (id, name, description, key, secret, status, user_id) FROM stdin;
\.


--
-- Name: piston3_consumer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('piston3_consumer_id_seq', 1, false);


--
-- Data for Name: piston3_nonce; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY piston3_nonce (id, token_key, consumer_key, key) FROM stdin;
\.


--
-- Name: piston3_nonce_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('piston3_nonce_id_seq', 1, false);


--
-- Data for Name: piston3_token; Type: TABLE DATA; Schema: public; Owner: gavin
--

COPY piston3_token (id, key, secret, verifier, token_type, "timestamp", is_approved, callback, callback_confirmed, consumer_id, user_id) FROM stdin;
\.


--
-- Name: piston3_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gavin
--

SELECT pg_catalog.setval('piston3_token_id_seq', 1, false);


--
-- Name: auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions_group_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_key UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission_content_type_id_codename_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_key UNIQUE (content_type_id, codename);


--
-- Name: auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_email_6cbacbe59d8dbc0b_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_email_6cbacbe59d8dbc0b_uniq UNIQUE (email);


--
-- Name: auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_user_id_group_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_key UNIQUE (user_id, group_id);


--
-- Name: auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_user_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_key UNIQUE (user_id, permission_id);


--
-- Name: auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: django_content_type_app_label_2763803367ade2ca_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_app_label_2763803367ade2ca_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: django_site_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);


--
-- Name: maasserver_blockdevice_node_id_cd58faa4d465ab2_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_blockdevice
    ADD CONSTRAINT maasserver_blockdevice_node_id_cd58faa4d465ab2_uniq UNIQUE (node_id, name);


--
-- Name: maasserver_blockdevice_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_blockdevice
    ADD CONSTRAINT maasserver_blockdevice_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bmc_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmc
    ADD CONSTRAINT maasserver_bmc_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bmc_power_type_5acf99678891cc49_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmc
    ADD CONSTRAINT maasserver_bmc_power_type_5acf99678891cc49_uniq UNIQUE (power_type, power_parameters, ip_address_id);


--
-- Name: maasserver_bmcroutablerackcontrollerrelationship_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmcroutablerackcontrollerrelationship
    ADD CONSTRAINT maasserver_bmcroutablerackcontrollerrelationship_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bootresource_name_6f0c9282394e2223_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresource
    ADD CONSTRAINT maasserver_bootresource_name_6f0c9282394e2223_uniq UNIQUE (name, architecture);


--
-- Name: maasserver_bootresource_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresource
    ADD CONSTRAINT maasserver_bootresource_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bootresourcefi_resource_set_id_1e8d78834b958427_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourcefile
    ADD CONSTRAINT maasserver_bootresourcefi_resource_set_id_1e8d78834b958427_uniq UNIQUE (resource_set_id, filename);


--
-- Name: maasserver_bootresourcefile_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourcefile
    ADD CONSTRAINT maasserver_bootresourcefile_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bootresourceset_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourceset
    ADD CONSTRAINT maasserver_bootresourceset_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bootresourceset_resource_id_77c5d2df474ec1e8_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourceset
    ADD CONSTRAINT maasserver_bootresourceset_resource_id_77c5d2df474ec1e8_uniq UNIQUE (resource_id, version);


--
-- Name: maasserver_bootsource_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsource
    ADD CONSTRAINT maasserver_bootsource_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bootsource_url_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsource
    ADD CONSTRAINT maasserver_bootsource_url_key UNIQUE (url);


--
-- Name: maasserver_bootsourcecache_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourcecache
    ADD CONSTRAINT maasserver_bootsourcecache_pkey PRIMARY KEY (id);


--
-- Name: maasserver_bootsourceselec_boot_source_id_2a48c94ff874e278_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourceselection
    ADD CONSTRAINT maasserver_bootsourceselec_boot_source_id_2a48c94ff874e278_uniq UNIQUE (boot_source_id, os, release);


--
-- Name: maasserver_bootsourceselection_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourceselection
    ADD CONSTRAINT maasserver_bootsourceselection_pkey PRIMARY KEY (id);


--
-- Name: maasserver_cacheset_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_cacheset
    ADD CONSTRAINT maasserver_cacheset_pkey PRIMARY KEY (id);


--
-- Name: maasserver_chassishints_chassis_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_chassishints
    ADD CONSTRAINT maasserver_chassishints_chassis_id_key UNIQUE (chassis_id);


--
-- Name: maasserver_chassishints_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_chassishints
    ADD CONSTRAINT maasserver_chassishints_pkey PRIMARY KEY (id);


--
-- Name: maasserver_componenterror_component_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_componenterror
    ADD CONSTRAINT maasserver_componenterror_component_key UNIQUE (component);


--
-- Name: maasserver_componenterror_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_componenterror
    ADD CONSTRAINT maasserver_componenterror_pkey PRIMARY KEY (id);


--
-- Name: maasserver_config_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_config
    ADD CONSTRAINT maasserver_config_name_key UNIQUE (name);


--
-- Name: maasserver_config_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_config
    ADD CONSTRAINT maasserver_config_pkey PRIMARY KEY (id);


--
-- Name: maasserver_dhcpsnippet_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dhcpsnippet
    ADD CONSTRAINT maasserver_dhcpsnippet_pkey PRIMARY KEY (id);


--
-- Name: maasserver_dnsdata_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsdata
    ADD CONSTRAINT maasserver_dnsdata_pkey PRIMARY KEY (id);


--
-- Name: maasserver_dnspublication_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnspublication
    ADD CONSTRAINT maasserver_dnspublication_pkey PRIMARY KEY (id);


--
-- Name: maasserver_dnsresource_ip_add_dnsresource_id_staticipaddres_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource_ip_addresses
    ADD CONSTRAINT maasserver_dnsresource_ip_add_dnsresource_id_staticipaddres_key UNIQUE (dnsresource_id, staticipaddress_id);


--
-- Name: maasserver_dnsresource_ip_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource_ip_addresses
    ADD CONSTRAINT maasserver_dnsresource_ip_addresses_pkey PRIMARY KEY (id);


--
-- Name: maasserver_dnsresource_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource
    ADD CONSTRAINT maasserver_dnsresource_pkey PRIMARY KEY (id);


--
-- Name: maasserver_domain_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_domain
    ADD CONSTRAINT maasserver_domain_name_key UNIQUE (name);


--
-- Name: maasserver_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_domain
    ADD CONSTRAINT maasserver_domain_pkey PRIMARY KEY (id);


--
-- Name: maasserver_event_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_event
    ADD CONSTRAINT maasserver_event_pkey PRIMARY KEY (id);


--
-- Name: maasserver_eventtype_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_eventtype
    ADD CONSTRAINT maasserver_eventtype_name_key UNIQUE (name);


--
-- Name: maasserver_eventtype_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_eventtype
    ADD CONSTRAINT maasserver_eventtype_pkey PRIMARY KEY (id);


--
-- Name: maasserver_fabric_name_26790438ba1d6093_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fabric
    ADD CONSTRAINT maasserver_fabric_name_26790438ba1d6093_uniq UNIQUE (name);


--
-- Name: maasserver_fabric_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fabric
    ADD CONSTRAINT maasserver_fabric_pkey PRIMARY KEY (id);


--
-- Name: maasserver_fannetwork_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fannetwork
    ADD CONSTRAINT maasserver_fannetwork_name_key UNIQUE (name);


--
-- Name: maasserver_fannetwork_overlay_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fannetwork
    ADD CONSTRAINT maasserver_fannetwork_overlay_key UNIQUE ("overlay");


--
-- Name: maasserver_fannetwork_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fannetwork
    ADD CONSTRAINT maasserver_fannetwork_pkey PRIMARY KEY (id);


--
-- Name: maasserver_fannetwork_underlay_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_fannetwork
    ADD CONSTRAINT maasserver_fannetwork_underlay_key UNIQUE (underlay);


--
-- Name: maasserver_filestorage_filename_367ceb3fa7f1e5d0_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filestorage
    ADD CONSTRAINT maasserver_filestorage_filename_367ceb3fa7f1e5d0_uniq UNIQUE (filename, owner_id);


--
-- Name: maasserver_filestorage_key_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filestorage
    ADD CONSTRAINT maasserver_filestorage_key_key UNIQUE (key);


--
-- Name: maasserver_filestorage_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filestorage
    ADD CONSTRAINT maasserver_filestorage_pkey PRIMARY KEY (id);


--
-- Name: maasserver_filesystem_block_device_id_7c3577060f097153_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT maasserver_filesystem_block_device_id_7c3577060f097153_uniq UNIQUE (block_device_id, acquired);


--
-- Name: maasserver_filesystem_partition_id_773635d031efb527_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT maasserver_filesystem_partition_id_773635d031efb527_uniq UNIQUE (partition_id, acquired);


--
-- Name: maasserver_filesystem_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT maasserver_filesystem_pkey PRIMARY KEY (id);


--
-- Name: maasserver_filesystemgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystemgroup
    ADD CONSTRAINT maasserver_filesystemgroup_pkey PRIMARY KEY (id);


--
-- Name: maasserver_filesystemgroup_uuid_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystemgroup
    ADD CONSTRAINT maasserver_filesystemgroup_uuid_key UNIQUE (uuid);


--
-- Name: maasserver_interface_ip_addre_interface_id_staticipaddress__key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface_ip_addresses
    ADD CONSTRAINT maasserver_interface_ip_addre_interface_id_staticipaddress__key UNIQUE (interface_id, staticipaddress_id);


--
-- Name: maasserver_interface_ip_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface_ip_addresses
    ADD CONSTRAINT maasserver_interface_ip_addresses_pkey PRIMARY KEY (id);


--
-- Name: maasserver_interface_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface
    ADD CONSTRAINT maasserver_interface_pkey PRIMARY KEY (id);


--
-- Name: maasserver_interfacerelationship_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interfacerelationship
    ADD CONSTRAINT maasserver_interfacerelationship_pkey PRIMARY KEY (id);


--
-- Name: maasserver_iprange_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_iprange
    ADD CONSTRAINT maasserver_iprange_pkey PRIMARY KEY (id);


--
-- Name: maasserver_keysource_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_keysource
    ADD CONSTRAINT maasserver_keysource_pkey PRIMARY KEY (id);


--
-- Name: maasserver_largefile_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_largefile
    ADD CONSTRAINT maasserver_largefile_pkey PRIMARY KEY (id);


--
-- Name: maasserver_largefile_sha256_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_largefile
    ADD CONSTRAINT maasserver_largefile_sha256_key UNIQUE (sha256);


--
-- Name: maasserver_licensekey_osystem_5812b564781719ea_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_licensekey
    ADD CONSTRAINT maasserver_licensekey_osystem_5812b564781719ea_uniq UNIQUE (osystem, distro_series);


--
-- Name: maasserver_licensekey_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_licensekey
    ADD CONSTRAINT maasserver_licensekey_pkey PRIMARY KEY (id);


--
-- Name: maasserver_mdns_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_mdns
    ADD CONSTRAINT maasserver_mdns_pkey PRIMARY KEY (id);


--
-- Name: maasserver_neighbour_interface_id_6b29cbb51ead8888_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_neighbour
    ADD CONSTRAINT maasserver_neighbour_interface_id_6b29cbb51ead8888_uniq UNIQUE (interface_id, vid, mac_address, ip);


--
-- Name: maasserver_neighbour_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_neighbour
    ADD CONSTRAINT maasserver_neighbour_pkey PRIMARY KEY (id);


--
-- Name: maasserver_node_dns_process_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_dns_process_id_key UNIQUE (dns_process_id);


--
-- Name: maasserver_node_hostname_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_hostname_key UNIQUE (hostname);


--
-- Name: maasserver_node_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_pkey PRIMARY KEY (id);


--
-- Name: maasserver_node_system_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_system_id_key UNIQUE (system_id);


--
-- Name: maasserver_node_tags_node_id_tag_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node_tags
    ADD CONSTRAINT maasserver_node_tags_node_id_tag_id_key UNIQUE (node_id, tag_id);


--
-- Name: maasserver_node_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node_tags
    ADD CONSTRAINT maasserver_node_tags_pkey PRIMARY KEY (id);


--
-- Name: maasserver_nodegrouptorackcontroller_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_nodegrouptorackcontroller
    ADD CONSTRAINT maasserver_nodegrouptorackcontroller_pkey PRIMARY KEY (id);


--
-- Name: maasserver_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_notification
    ADD CONSTRAINT maasserver_notification_pkey PRIMARY KEY (id);


--
-- Name: maasserver_ownerdata_node_id_3340330b54ba1e85_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_ownerdata
    ADD CONSTRAINT maasserver_ownerdata_node_id_3340330b54ba1e85_uniq UNIQUE (node_id, key);


--
-- Name: maasserver_ownerdata_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_ownerdata
    ADD CONSTRAINT maasserver_ownerdata_pkey PRIMARY KEY (id);


--
-- Name: maasserver_packagerepository_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_packagerepository
    ADD CONSTRAINT maasserver_packagerepository_name_key UNIQUE (name);


--
-- Name: maasserver_packagerepository_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_packagerepository
    ADD CONSTRAINT maasserver_packagerepository_pkey PRIMARY KEY (id);


--
-- Name: maasserver_partition_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partition
    ADD CONSTRAINT maasserver_partition_pkey PRIMARY KEY (id);


--
-- Name: maasserver_partition_uuid_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partition
    ADD CONSTRAINT maasserver_partition_uuid_key UNIQUE (uuid);


--
-- Name: maasserver_partitiontable_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partitiontable
    ADD CONSTRAINT maasserver_partitiontable_pkey PRIMARY KEY (id);


--
-- Name: maasserver_physicalblockdevice_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_physicalblockdevice
    ADD CONSTRAINT maasserver_physicalblockdevice_pkey PRIMARY KEY (blockdevice_ptr_id);


--
-- Name: maasserver_rdns_ip_59f823ff855f3d03_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_rdns
    ADD CONSTRAINT maasserver_rdns_ip_59f823ff855f3d03_uniq UNIQUE (ip, observer_id);


--
-- Name: maasserver_rdns_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_rdns
    ADD CONSTRAINT maasserver_rdns_pkey PRIMARY KEY (id);


--
-- Name: maasserver_regioncontrollerpro_process_id_181458d69aa56c8d_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocessendpoint
    ADD CONSTRAINT maasserver_regioncontrollerpro_process_id_181458d69aa56c8d_uniq UNIQUE (process_id, address, port);


--
-- Name: maasserver_regioncontrollerproc_region_id_261c6f2efc3d891d_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocess
    ADD CONSTRAINT maasserver_regioncontrollerproc_region_id_261c6f2efc3d891d_uniq UNIQUE (region_id, pid);


--
-- Name: maasserver_regioncontrollerprocess_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocess
    ADD CONSTRAINT maasserver_regioncontrollerprocess_pkey PRIMARY KEY (id);


--
-- Name: maasserver_regioncontrollerprocessendpoint_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocessendpoint
    ADD CONSTRAINT maasserver_regioncontrollerprocessendpoint_pkey PRIMARY KEY (id);


--
-- Name: maasserver_regionrackrpcconne_endpoint_id_214119acf37789dd_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regionrackrpcconnection
    ADD CONSTRAINT maasserver_regionrackrpcconne_endpoint_id_214119acf37789dd_uniq UNIQUE (endpoint_id, rack_controller_id);


--
-- Name: maasserver_regionrackrpcconnection_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regionrackrpcconnection
    ADD CONSTRAINT maasserver_regionrackrpcconnection_pkey PRIMARY KEY (id);


--
-- Name: maasserver_service_node_id_23e3570fe1b038ec_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_service
    ADD CONSTRAINT maasserver_service_node_id_23e3570fe1b038ec_uniq UNIQUE (node_id, name);


--
-- Name: maasserver_service_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_service
    ADD CONSTRAINT maasserver_service_pkey PRIMARY KEY (id);


--
-- Name: maasserver_space_name_2a0e730b4a52e34d_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_space
    ADD CONSTRAINT maasserver_space_name_2a0e730b4a52e34d_uniq UNIQUE (name);


--
-- Name: maasserver_space_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_space
    ADD CONSTRAINT maasserver_space_pkey PRIMARY KEY (id);


--
-- Name: maasserver_sshkey_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sshkey
    ADD CONSTRAINT maasserver_sshkey_pkey PRIMARY KEY (id);


--
-- Name: maasserver_sshkey_user_id_41fe234e568377ee_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sshkey
    ADD CONSTRAINT maasserver_sshkey_user_id_41fe234e568377ee_uniq UNIQUE (user_id, key, keysource_id);


--
-- Name: maasserver_sslkey_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sslkey
    ADD CONSTRAINT maasserver_sslkey_pkey PRIMARY KEY (id);


--
-- Name: maasserver_sslkey_user_id_17308820f6e805ad_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sslkey
    ADD CONSTRAINT maasserver_sslkey_user_id_17308820f6e805ad_uniq UNIQUE (user_id, key);


--
-- Name: maasserver_staticipaddress_ip_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticipaddress
    ADD CONSTRAINT maasserver_staticipaddress_ip_key UNIQUE (ip);


--
-- Name: maasserver_staticipaddress_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticipaddress
    ADD CONSTRAINT maasserver_staticipaddress_pkey PRIMARY KEY (id);


--
-- Name: maasserver_staticroute_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticroute
    ADD CONSTRAINT maasserver_staticroute_pkey PRIMARY KEY (id);


--
-- Name: maasserver_staticroute_source_id_7d3a9fa61e5f37e5_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticroute
    ADD CONSTRAINT maasserver_staticroute_source_id_7d3a9fa61e5f37e5_uniq UNIQUE (source_id, destination_id, gateway_ip);


--
-- Name: maasserver_subnet_cidr_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_subnet
    ADD CONSTRAINT maasserver_subnet_cidr_key UNIQUE (cidr);


--
-- Name: maasserver_subnet_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_subnet
    ADD CONSTRAINT maasserver_subnet_pkey PRIMARY KEY (id);


--
-- Name: maasserver_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_tag
    ADD CONSTRAINT maasserver_tag_name_key UNIQUE (name);


--
-- Name: maasserver_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_tag
    ADD CONSTRAINT maasserver_tag_pkey PRIMARY KEY (id);


--
-- Name: maasserver_template_filename_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_template
    ADD CONSTRAINT maasserver_template_filename_key UNIQUE (filename);


--
-- Name: maasserver_template_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_template
    ADD CONSTRAINT maasserver_template_pkey PRIMARY KEY (id);


--
-- Name: maasserver_userprofile_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_userprofile
    ADD CONSTRAINT maasserver_userprofile_pkey PRIMARY KEY (id);


--
-- Name: maasserver_userprofile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_userprofile
    ADD CONSTRAINT maasserver_userprofile_user_id_key UNIQUE (user_id);


--
-- Name: maasserver_versionedtextfile_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_versionedtextfile
    ADD CONSTRAINT maasserver_versionedtextfile_pkey PRIMARY KEY (id);


--
-- Name: maasserver_virtualblockdevice_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_virtualblockdevice
    ADD CONSTRAINT maasserver_virtualblockdevice_pkey PRIMARY KEY (blockdevice_ptr_id);


--
-- Name: maasserver_virtualblockdevice_uuid_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_virtualblockdevice
    ADD CONSTRAINT maasserver_virtualblockdevice_uuid_key UNIQUE (uuid);


--
-- Name: maasserver_vlan_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasserver_vlan_pkey PRIMARY KEY (id);


--
-- Name: maasserver_vlan_vid_32a19e4c0d6b40ab_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasserver_vlan_vid_32a19e4c0d6b40ab_uniq UNIQUE (vid, fabric_id);


--
-- Name: maasserver_zone_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_zone
    ADD CONSTRAINT maasserver_zone_name_key UNIQUE (name);


--
-- Name: maasserver_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_zone
    ADD CONSTRAINT maasserver_zone_pkey PRIMARY KEY (id);


--
-- Name: metadataserver_commissioningscript_name_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_commissioningscript
    ADD CONSTRAINT metadataserver_commissioningscript_name_key UNIQUE (name);


--
-- Name: metadataserver_commissioningscript_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_commissioningscript
    ADD CONSTRAINT metadataserver_commissioningscript_pkey PRIMARY KEY (id);


--
-- Name: metadataserver_nodekey_key_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey
    ADD CONSTRAINT metadataserver_nodekey_key_key UNIQUE (key);


--
-- Name: metadataserver_nodekey_node_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey
    ADD CONSTRAINT metadataserver_nodekey_node_id_key UNIQUE (node_id);


--
-- Name: metadataserver_nodekey_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey
    ADD CONSTRAINT metadataserver_nodekey_pkey PRIMARY KEY (id);


--
-- Name: metadataserver_nodekey_token_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey
    ADD CONSTRAINT metadataserver_nodekey_token_id_key UNIQUE (token_id);


--
-- Name: metadataserver_noderesult_node_id_762fa770c4ceb809_uniq; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_noderesult
    ADD CONSTRAINT metadataserver_noderesult_node_id_762fa770c4ceb809_uniq UNIQUE (node_id, name);


--
-- Name: metadataserver_noderesult_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_noderesult
    ADD CONSTRAINT metadataserver_noderesult_pkey PRIMARY KEY (id);


--
-- Name: metadataserver_nodeuserdata_node_id_key; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodeuserdata
    ADD CONSTRAINT metadataserver_nodeuserdata_node_id_key UNIQUE (node_id);


--
-- Name: metadataserver_nodeuserdata_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodeuserdata
    ADD CONSTRAINT metadataserver_nodeuserdata_pkey PRIMARY KEY (id);


--
-- Name: piston3_consumer_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_consumer
    ADD CONSTRAINT piston3_consumer_pkey PRIMARY KEY (id);


--
-- Name: piston3_nonce_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_nonce
    ADD CONSTRAINT piston3_nonce_pkey PRIMARY KEY (id);


--
-- Name: piston3_token_pkey; Type: CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_token
    ADD CONSTRAINT piston3_token_pkey PRIMARY KEY (id);


--
-- Name: auth_group_name_5af470e0b96b95b9_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_group_name_5af470e0b96b95b9_like ON auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_0e939a4f; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_group_permissions_0e939a4f ON auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_8373b171; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_group_permissions_8373b171 ON auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_417f1b1c; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_permission_417f1b1c ON auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_0e939a4f; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_user_groups_0e939a4f ON auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_user_groups_e8701ad4 ON auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_8373b171; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_user_user_permissions_8373b171 ON auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_user_user_permissions_e8701ad4 ON auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_61b373fe2e4bc87_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX auth_user_username_61b373fe2e4bc87_like ON auth_user USING btree (username varchar_pattern_ops);


--
-- Name: django_session_de54fa62; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX django_session_de54fa62 ON django_session USING btree (expire_date);


--
-- Name: django_session_session_key_5e143b4f2ace0cb5_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX django_session_session_key_5e143b4f2ace0cb5_like ON django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: maasserver_blockdevice_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_blockdevice_c693ebc8 ON maasserver_blockdevice USING btree (node_id);


--
-- Name: maasserver_bmc_3af51f48; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bmc_3af51f48 ON maasserver_bmc USING btree (ip_address_id);


--
-- Name: maasserver_bmcroutablerackcontrollerrelationship_ccba0524; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bmcroutablerackcontrollerrelationship_ccba0524 ON maasserver_bmcroutablerackcontrollerrelationship USING btree (rack_controller_id);


--
-- Name: maasserver_bmcroutablerackcontrollerrelationship_e182f516; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bmcroutablerackcontrollerrelationship_e182f516 ON maasserver_bmcroutablerackcontrollerrelationship USING btree (bmc_id);


--
-- Name: maasserver_bootresourcefile_770a4a6a; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bootresourcefile_770a4a6a ON maasserver_bootresourcefile USING btree (resource_set_id);


--
-- Name: maasserver_bootresourcefile_7deea471; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bootresourcefile_7deea471 ON maasserver_bootresourcefile USING btree (largefile_id);


--
-- Name: maasserver_bootresourceset_e2f3ef5b; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bootresourceset_e2f3ef5b ON maasserver_bootresourceset USING btree (resource_id);


--
-- Name: maasserver_bootsource_url_5fdd8ca9360f03c3_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bootsource_url_5fdd8ca9360f03c3_like ON maasserver_bootsource USING btree (url varchar_pattern_ops);


--
-- Name: maasserver_bootsourcecache_93d77297; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bootsourcecache_93d77297 ON maasserver_bootsourcecache USING btree (boot_source_id);


--
-- Name: maasserver_bootsourceselection_93d77297; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_bootsourceselection_93d77297 ON maasserver_bootsourceselection USING btree (boot_source_id);


--
-- Name: maasserver_componenterror_component_5d128f096198b7cd_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_componenterror_component_5d128f096198b7cd_like ON maasserver_componenterror USING btree (component varchar_pattern_ops);


--
-- Name: maasserver_config_name_61b7df5f6a1fa7da_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_config_name_61b7df5f6a1fa7da_like ON maasserver_config USING btree (name varchar_pattern_ops);


--
-- Name: maasserver_dhcpsnippet_b0304493; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dhcpsnippet_b0304493 ON maasserver_dhcpsnippet USING btree (value_id);


--
-- Name: maasserver_dhcpsnippet_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dhcpsnippet_c693ebc8 ON maasserver_dhcpsnippet USING btree (node_id);


--
-- Name: maasserver_dhcpsnippet_fe866fcb; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dhcpsnippet_fe866fcb ON maasserver_dhcpsnippet USING btree (subnet_id);


--
-- Name: maasserver_dnsdata_58d0cea5; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dnsdata_58d0cea5 ON maasserver_dnsdata USING btree (dnsresource_id);


--
-- Name: maasserver_dnsresource_662cbf12; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dnsresource_662cbf12 ON maasserver_dnsresource USING btree (domain_id);


--
-- Name: maasserver_dnsresource_ip_addresses_58d0cea5; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dnsresource_ip_addresses_58d0cea5 ON maasserver_dnsresource_ip_addresses USING btree (dnsresource_id);


--
-- Name: maasserver_dnsresource_ip_addresses_7773056d; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_dnsresource_ip_addresses_7773056d ON maasserver_dnsresource_ip_addresses USING btree (staticipaddress_id);


--
-- Name: maasserver_domain_946f3fba; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_domain_946f3fba ON maasserver_domain USING btree (authoritative);


--
-- Name: maasserver_domain_name_507381174bb8f7eb_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_domain_name_507381174bb8f7eb_like ON maasserver_domain USING btree (name varchar_pattern_ops);


--
-- Name: maasserver_event_94757cae; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_event_94757cae ON maasserver_event USING btree (type_id);


--
-- Name: maasserver_event_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_event_c693ebc8 ON maasserver_event USING btree (node_id);


--
-- Name: maasserver_event_node_id_16ff7f8b7bf14048_idx; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_event_node_id_16ff7f8b7bf14048_idx ON maasserver_event USING btree (node_id, id);


--
-- Name: maasserver_eventtype_c9e9a848; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_eventtype_c9e9a848 ON maasserver_eventtype USING btree (level);


--
-- Name: maasserver_eventtype_name_abed69a2acc93b4_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_eventtype_name_abed69a2acc93b4_like ON maasserver_eventtype USING btree (name varchar_pattern_ops);


--
-- Name: maasserver_fannetwork_name_42594f0626b23337_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_fannetwork_name_42594f0626b23337_like ON maasserver_fannetwork USING btree (name varchar_pattern_ops);


--
-- Name: maasserver_filestorage_5e7b1936; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filestorage_5e7b1936 ON maasserver_filestorage USING btree (owner_id);


--
-- Name: maasserver_filestorage_key_6d3e970139d47028_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filestorage_key_6d3e970139d47028_like ON maasserver_filestorage USING btree (key varchar_pattern_ops);


--
-- Name: maasserver_filesystem_2f3347f9; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystem_2f3347f9 ON maasserver_filesystem USING btree (filesystem_group_id);


--
-- Name: maasserver_filesystem_5e15e269; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystem_5e15e269 ON maasserver_filesystem USING btree (block_device_id);


--
-- Name: maasserver_filesystem_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystem_c693ebc8 ON maasserver_filesystem USING btree (node_id);


--
-- Name: maasserver_filesystem_da479efe; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystem_da479efe ON maasserver_filesystem USING btree (partition_id);


--
-- Name: maasserver_filesystem_f098899f; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystem_f098899f ON maasserver_filesystem USING btree (cache_set_id);


--
-- Name: maasserver_filesystemgroup_f098899f; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystemgroup_f098899f ON maasserver_filesystemgroup USING btree (cache_set_id);


--
-- Name: maasserver_filesystemgroup_uuid_3337eade4aaf188a_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_filesystemgroup_uuid_3337eade4aaf188a_like ON maasserver_filesystemgroup USING btree (uuid varchar_pattern_ops);


--
-- Name: maasserver_interface_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_interface_c693ebc8 ON maasserver_interface USING btree (node_id);


--
-- Name: maasserver_interface_cd1dc8b7; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_interface_cd1dc8b7 ON maasserver_interface USING btree (vlan_id);


--
-- Name: maasserver_interface_ip_addresses_7773056d; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_interface_ip_addresses_7773056d ON maasserver_interface_ip_addresses USING btree (staticipaddress_id);


--
-- Name: maasserver_interface_ip_addresses_991706b3; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_interface_ip_addresses_991706b3 ON maasserver_interface_ip_addresses USING btree (interface_id);


--
-- Name: maasserver_interfacerelationship_6be37982; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_interfacerelationship_6be37982 ON maasserver_interfacerelationship USING btree (parent_id);


--
-- Name: maasserver_interfacerelationship_f36263a3; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_interfacerelationship_f36263a3 ON maasserver_interfacerelationship USING btree (child_id);


--
-- Name: maasserver_iprange_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_iprange_e8701ad4 ON maasserver_iprange USING btree (user_id);


--
-- Name: maasserver_iprange_fe866fcb; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_iprange_fe866fcb ON maasserver_iprange USING btree (subnet_id);


--
-- Name: maasserver_largefile_sha256_5988bcedc73b56d5_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_largefile_sha256_5988bcedc73b56d5_like ON maasserver_largefile USING btree (sha256 varchar_pattern_ops);


--
-- Name: maasserver_mdns_991706b3; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_mdns_991706b3 ON maasserver_mdns USING btree (interface_id);


--
-- Name: maasserver_neighbour_991706b3; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_neighbour_991706b3 ON maasserver_neighbour USING btree (interface_id);


--
-- Name: maasserver_node_06342dd7; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_06342dd7 ON maasserver_node USING btree (zone_id);


--
-- Name: maasserver_node_4eb4a6b7; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_4eb4a6b7 ON maasserver_node USING btree (gateway_link_ipv4_id);


--
-- Name: maasserver_node_55d551ed; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_55d551ed ON maasserver_node USING btree (token_id);


--
-- Name: maasserver_node_5e7b1936; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_5e7b1936 ON maasserver_node USING btree (owner_id);


--
-- Name: maasserver_node_662cbf12; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_662cbf12 ON maasserver_node USING btree (domain_id);


--
-- Name: maasserver_node_6be37982; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_6be37982 ON maasserver_node USING btree (parent_id);


--
-- Name: maasserver_node_888a6f50; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_888a6f50 ON maasserver_node USING btree (boot_interface_id);


--
-- Name: maasserver_node_8f61c804; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_8f61c804 ON maasserver_node USING btree (managing_process_id);


--
-- Name: maasserver_node_98e26801; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_98e26801 ON maasserver_node USING btree (boot_disk_id);


--
-- Name: maasserver_node_c1526556; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_c1526556 ON maasserver_node USING btree (gateway_link_ipv6_id);


--
-- Name: maasserver_node_e182f516; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_e182f516 ON maasserver_node USING btree (bmc_id);


--
-- Name: maasserver_node_hostname_287ebcdf0d057d08_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_hostname_287ebcdf0d057d08_like ON maasserver_node USING btree (hostname varchar_pattern_ops);


--
-- Name: maasserver_node_system_id_1ed62c2b515a5cce_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_system_id_1ed62c2b515a5cce_like ON maasserver_node USING btree (system_id varchar_pattern_ops);


--
-- Name: maasserver_node_tags_76f094bc; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_tags_76f094bc ON maasserver_node_tags USING btree (tag_id);


--
-- Name: maasserver_node_tags_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_node_tags_c693ebc8 ON maasserver_node_tags USING btree (node_id);


--
-- Name: maasserver_nodegrouptorackcontroller_fe866fcb; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_nodegrouptorackcontroller_fe866fcb ON maasserver_nodegrouptorackcontroller USING btree (subnet_id);


--
-- Name: maasserver_notification_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_notification_e8701ad4 ON maasserver_notification USING btree (user_id);


--
-- Name: maasserver_notification_ident; Type: INDEX; Schema: public; Owner: gavin
--

CREATE UNIQUE INDEX maasserver_notification_ident ON maasserver_notification USING btree (ident) WHERE (ident IS NOT NULL);


--
-- Name: maasserver_ownerdata_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_ownerdata_c693ebc8 ON maasserver_ownerdata USING btree (node_id);


--
-- Name: maasserver_packagerepository_name_55fc2a87d5e180e6_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_packagerepository_name_55fc2a87d5e180e6_like ON maasserver_packagerepository USING btree (name varchar_pattern_ops);


--
-- Name: maasserver_partition_b3f74362; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_partition_b3f74362 ON maasserver_partition USING btree (partition_table_id);


--
-- Name: maasserver_partition_uuid_2dbdcb6de4d62bf9_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_partition_uuid_2dbdcb6de4d62bf9_like ON maasserver_partition USING btree (uuid varchar_pattern_ops);


--
-- Name: maasserver_partitiontable_5e15e269; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_partitiontable_5e15e269 ON maasserver_partitiontable USING btree (block_device_id);


--
-- Name: maasserver_rdns_b5aa8205; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_rdns_b5aa8205 ON maasserver_rdns USING btree (observer_id);


--
-- Name: maasserver_regioncontrollerprocess_0f442f96; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_regioncontrollerprocess_0f442f96 ON maasserver_regioncontrollerprocess USING btree (region_id);


--
-- Name: maasserver_regioncontrollerprocessendpoint_c9cf7ee8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_regioncontrollerprocessendpoint_c9cf7ee8 ON maasserver_regioncontrollerprocessendpoint USING btree (process_id);


--
-- Name: maasserver_regionrackrpcconnection_955e573e; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_regionrackrpcconnection_955e573e ON maasserver_regionrackrpcconnection USING btree (endpoint_id);


--
-- Name: maasserver_regionrackrpcconnection_ccba0524; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_regionrackrpcconnection_ccba0524 ON maasserver_regionrackrpcconnection USING btree (rack_controller_id);


--
-- Name: maasserver_service_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_service_c693ebc8 ON maasserver_service USING btree (node_id);


--
-- Name: maasserver_sshkey_ceb61aa3; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_sshkey_ceb61aa3 ON maasserver_sshkey USING btree (keysource_id);


--
-- Name: maasserver_sshkey_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_sshkey_e8701ad4 ON maasserver_sshkey USING btree (user_id);


--
-- Name: maasserver_sslkey_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_sslkey_e8701ad4 ON maasserver_sslkey USING btree (user_id);


--
-- Name: maasserver_staticipaddress_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_staticipaddress_e8701ad4 ON maasserver_staticipaddress USING btree (user_id);


--
-- Name: maasserver_staticipaddress_fe866fcb; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_staticipaddress_fe866fcb ON maasserver_staticipaddress USING btree (subnet_id);


--
-- Name: maasserver_staticroute_0afd9202; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_staticroute_0afd9202 ON maasserver_staticroute USING btree (source_id);


--
-- Name: maasserver_staticroute_279358a3; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_staticroute_279358a3 ON maasserver_staticroute USING btree (destination_id);


--
-- Name: maasserver_subnet_cd1dc8b7; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_subnet_cd1dc8b7 ON maasserver_subnet USING btree (vlan_id);


--
-- Name: maasserver_tag_name_770a739b05ac7c70_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_tag_name_770a739b05ac7c70_like ON maasserver_tag USING btree (name varchar_pattern_ops);


--
-- Name: maasserver_template_316e8552; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_template_316e8552 ON maasserver_template USING btree (version_id);


--
-- Name: maasserver_template_9fa167e5; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_template_9fa167e5 ON maasserver_template USING btree (default_version_id);


--
-- Name: maasserver_template_filename_55aee16178ca872_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_template_filename_55aee16178ca872_like ON maasserver_template USING btree (filename varchar_pattern_ops);


--
-- Name: maasserver_versionedtextfile_5c3aef85; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_versionedtextfile_5c3aef85 ON maasserver_versionedtextfile USING btree (previous_version_id);


--
-- Name: maasserver_virtualblockdevice_2f3347f9; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_virtualblockdevice_2f3347f9 ON maasserver_virtualblockdevice USING btree (filesystem_group_id);


--
-- Name: maasserver_virtualblockdevice_uuid_6fc817e2bea6f7aa_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_virtualblockdevice_uuid_6fc817e2bea6f7aa_like ON maasserver_virtualblockdevice USING btree (uuid varchar_pattern_ops);


--
-- Name: maasserver_vlan_0c4809fb; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_vlan_0c4809fb ON maasserver_vlan USING btree (fabric_id);


--
-- Name: maasserver_vlan_6961fc1b; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_vlan_6961fc1b ON maasserver_vlan USING btree (primary_rack_id);


--
-- Name: maasserver_vlan_84defa73; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_vlan_84defa73 ON maasserver_vlan USING btree (space_id);


--
-- Name: maasserver_vlan_a6b3d502; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_vlan_a6b3d502 ON maasserver_vlan USING btree (secondary_rack_id);


--
-- Name: maasserver_vlan_a8226f8a; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_vlan_a8226f8a ON maasserver_vlan USING btree (relay_vlan_id);


--
-- Name: maasserver_zone_name_3df537723ceec731_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX maasserver_zone_name_3df537723ceec731_like ON maasserver_zone USING btree (name varchar_pattern_ops);


--
-- Name: metadataserver_commissioningscript_name_63474e6c7cd9dc5c_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX metadataserver_commissioningscript_name_63474e6c7cd9dc5c_like ON metadataserver_commissioningscript USING btree (name varchar_pattern_ops);


--
-- Name: metadataserver_nodekey_key_60e853fedacb2f68_like; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX metadataserver_nodekey_key_60e853fedacb2f68_like ON metadataserver_nodekey USING btree (key varchar_pattern_ops);


--
-- Name: metadataserver_noderesult_c693ebc8; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX metadataserver_noderesult_c693ebc8 ON metadataserver_noderesult USING btree (node_id);


--
-- Name: piston3_consumer_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX piston3_consumer_e8701ad4 ON piston3_consumer USING btree (user_id);


--
-- Name: piston3_token_1db5a817; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX piston3_token_1db5a817 ON piston3_token USING btree (consumer_id);


--
-- Name: piston3_token_e8701ad4; Type: INDEX; Schema: public; Owner: gavin
--

CREATE INDEX piston3_token_e8701ad4 ON piston3_token USING btree (user_id);


--
-- Name: auth_user_user_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER auth_user_user_create_notify AFTER INSERT ON auth_user FOR EACH ROW EXECUTE PROCEDURE user_create_notify();


--
-- Name: auth_user_user_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER auth_user_user_delete_notify AFTER DELETE ON auth_user FOR EACH ROW EXECUTE PROCEDURE user_delete_notify();


--
-- Name: auth_user_user_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER auth_user_user_update_notify AFTER UPDATE ON auth_user FOR EACH ROW EXECUTE PROCEDURE user_update_notify();


--
-- Name: blockdevice_nd_blockdevice_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER blockdevice_nd_blockdevice_link_notify AFTER INSERT ON maasserver_blockdevice FOR EACH ROW EXECUTE PROCEDURE nd_blockdevice_link_notify();


--
-- Name: blockdevice_nd_blockdevice_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER blockdevice_nd_blockdevice_unlink_notify AFTER DELETE ON maasserver_blockdevice FOR EACH ROW EXECUTE PROCEDURE nd_blockdevice_unlink_notify();


--
-- Name: blockdevice_nd_blockdevice_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER blockdevice_nd_blockdevice_update_notify AFTER UPDATE ON maasserver_blockdevice FOR EACH ROW EXECUTE PROCEDURE nd_blockdevice_update_notify();


--
-- Name: cacheset_nd_cacheset_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER cacheset_nd_cacheset_link_notify AFTER INSERT ON maasserver_cacheset FOR EACH ROW EXECUTE PROCEDURE nd_cacheset_link_notify();


--
-- Name: cacheset_nd_cacheset_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER cacheset_nd_cacheset_unlink_notify AFTER DELETE ON maasserver_cacheset FOR EACH ROW EXECUTE PROCEDURE nd_cacheset_unlink_notify();


--
-- Name: cacheset_nd_cacheset_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER cacheset_nd_cacheset_update_notify AFTER UPDATE ON maasserver_cacheset FOR EACH ROW EXECUTE PROCEDURE nd_cacheset_update_notify();


--
-- Name: config_config_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_config_create_notify AFTER INSERT ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE config_create_notify();


--
-- Name: config_config_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_config_delete_notify AFTER DELETE ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE config_delete_notify();


--
-- Name: config_config_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_config_update_notify AFTER UPDATE ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE config_update_notify();


--
-- Name: config_sys_dhcp_config_ntp_servers_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_sys_dhcp_config_ntp_servers_delete AFTER DELETE ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_config_ntp_servers_delete();


--
-- Name: config_sys_dhcp_config_ntp_servers_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_sys_dhcp_config_ntp_servers_insert AFTER INSERT ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_config_ntp_servers_insert();


--
-- Name: config_sys_dhcp_config_ntp_servers_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_sys_dhcp_config_ntp_servers_update AFTER UPDATE ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_config_ntp_servers_update();


--
-- Name: config_sys_dns_config_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_sys_dns_config_insert AFTER INSERT ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE sys_dns_config_insert();


--
-- Name: config_sys_dns_config_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER config_sys_dns_config_update AFTER UPDATE ON maasserver_config FOR EACH ROW EXECUTE PROCEDURE sys_dns_config_update();


--
-- Name: dhcpsnippet_dhcpsnippet_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dhcpsnippet_dhcpsnippet_create_notify AFTER INSERT ON maasserver_dhcpsnippet FOR EACH ROW EXECUTE PROCEDURE dhcpsnippet_create_notify();


--
-- Name: dhcpsnippet_dhcpsnippet_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dhcpsnippet_dhcpsnippet_delete_notify AFTER DELETE ON maasserver_dhcpsnippet FOR EACH ROW EXECUTE PROCEDURE dhcpsnippet_delete_notify();


--
-- Name: dhcpsnippet_dhcpsnippet_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dhcpsnippet_dhcpsnippet_update_notify AFTER UPDATE ON maasserver_dhcpsnippet FOR EACH ROW EXECUTE PROCEDURE dhcpsnippet_update_notify();


--
-- Name: dhcpsnippet_sys_dhcp_snippet_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dhcpsnippet_sys_dhcp_snippet_delete AFTER DELETE ON maasserver_dhcpsnippet FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_snippet_delete();


--
-- Name: dhcpsnippet_sys_dhcp_snippet_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dhcpsnippet_sys_dhcp_snippet_insert AFTER INSERT ON maasserver_dhcpsnippet FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_snippet_insert();


--
-- Name: dhcpsnippet_sys_dhcp_snippet_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dhcpsnippet_sys_dhcp_snippet_update AFTER UPDATE ON maasserver_dhcpsnippet FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_snippet_update();


--
-- Name: dnsdata_dnsdata_domain_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsdata_dnsdata_domain_delete_notify AFTER DELETE ON maasserver_dnsdata FOR EACH ROW EXECUTE PROCEDURE dnsdata_domain_delete_notify();


--
-- Name: dnsdata_dnsdata_domain_insert_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsdata_dnsdata_domain_insert_notify AFTER INSERT ON maasserver_dnsdata FOR EACH ROW EXECUTE PROCEDURE dnsdata_domain_insert_notify();


--
-- Name: dnsdata_dnsdata_domain_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsdata_dnsdata_domain_update_notify AFTER UPDATE ON maasserver_dnsdata FOR EACH ROW EXECUTE PROCEDURE dnsdata_domain_update_notify();


--
-- Name: dnsdata_sys_dns_dnsdata_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsdata_sys_dns_dnsdata_delete AFTER DELETE ON maasserver_dnsdata FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsdata_delete();


--
-- Name: dnsdata_sys_dns_dnsdata_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsdata_sys_dns_dnsdata_insert AFTER INSERT ON maasserver_dnsdata FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsdata_insert();


--
-- Name: dnsdata_sys_dns_dnsdata_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsdata_sys_dns_dnsdata_update AFTER UPDATE ON maasserver_dnsdata FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsdata_update();


--
-- Name: dnspublication_sys_dns_publish; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnspublication_sys_dns_publish AFTER INSERT ON maasserver_dnspublication FOR EACH ROW EXECUTE PROCEDURE sys_dns_publish();


--
-- Name: dnsresource_dnsresource_domain_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_dnsresource_domain_delete_notify AFTER DELETE ON maasserver_dnsresource FOR EACH ROW EXECUTE PROCEDURE dnsresource_domain_delete_notify();


--
-- Name: dnsresource_dnsresource_domain_insert_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_dnsresource_domain_insert_notify AFTER INSERT ON maasserver_dnsresource FOR EACH ROW EXECUTE PROCEDURE dnsresource_domain_insert_notify();


--
-- Name: dnsresource_dnsresource_domain_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_dnsresource_domain_update_notify AFTER UPDATE ON maasserver_dnsresource FOR EACH ROW EXECUTE PROCEDURE dnsresource_domain_update_notify();


--
-- Name: dnsresource_ip_addresses_rrset_sipaddress_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_ip_addresses_rrset_sipaddress_link_notify AFTER INSERT ON maasserver_dnsresource_ip_addresses FOR EACH ROW EXECUTE PROCEDURE rrset_sipaddress_link_notify();


--
-- Name: dnsresource_ip_addresses_rrset_sipaddress_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_ip_addresses_rrset_sipaddress_unlink_notify AFTER DELETE ON maasserver_dnsresource_ip_addresses FOR EACH ROW EXECUTE PROCEDURE rrset_sipaddress_unlink_notify();


--
-- Name: dnsresource_ip_addresses_sys_dns_dnsresource_ip_link; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_ip_addresses_sys_dns_dnsresource_ip_link AFTER INSERT ON maasserver_dnsresource_ip_addresses FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsresource_ip_link();


--
-- Name: dnsresource_ip_addresses_sys_dns_dnsresource_ip_unlink; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_ip_addresses_sys_dns_dnsresource_ip_unlink AFTER DELETE ON maasserver_dnsresource_ip_addresses FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsresource_ip_unlink();


--
-- Name: dnsresource_sys_dns_dnsresource_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_sys_dns_dnsresource_delete AFTER DELETE ON maasserver_dnsresource FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsresource_delete();


--
-- Name: dnsresource_sys_dns_dnsresource_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_sys_dns_dnsresource_insert AFTER INSERT ON maasserver_dnsresource FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsresource_insert();


--
-- Name: dnsresource_sys_dns_dnsresource_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER dnsresource_sys_dns_dnsresource_update AFTER UPDATE ON maasserver_dnsresource FOR EACH ROW EXECUTE PROCEDURE sys_dns_dnsresource_update();


--
-- Name: domain_domain_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_domain_create_notify AFTER INSERT ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE domain_create_notify();


--
-- Name: domain_domain_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_domain_delete_notify AFTER DELETE ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE domain_delete_notify();


--
-- Name: domain_domain_node_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_domain_node_update_notify AFTER UPDATE ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE domain_node_update_notify();


--
-- Name: domain_domain_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_domain_update_notify AFTER UPDATE ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE domain_update_notify();


--
-- Name: domain_sys_dns_domain_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_sys_dns_domain_delete AFTER DELETE ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE sys_dns_domain_delete();


--
-- Name: domain_sys_dns_domain_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_sys_dns_domain_insert AFTER INSERT ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE sys_dns_domain_insert();


--
-- Name: domain_sys_dns_domain_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER domain_sys_dns_domain_update AFTER UPDATE ON maasserver_domain FOR EACH ROW EXECUTE PROCEDURE sys_dns_domain_update();


--
-- Name: event_event_create_machine_device_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER event_event_create_machine_device_notify AFTER INSERT ON maasserver_event FOR EACH ROW EXECUTE PROCEDURE event_create_machine_device_notify();


--
-- Name: event_event_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER event_event_create_notify AFTER INSERT ON maasserver_event FOR EACH ROW EXECUTE PROCEDURE event_create_notify();


--
-- Name: fabric_fabric_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER fabric_fabric_create_notify AFTER INSERT ON maasserver_fabric FOR EACH ROW EXECUTE PROCEDURE fabric_create_notify();


--
-- Name: fabric_fabric_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER fabric_fabric_delete_notify AFTER DELETE ON maasserver_fabric FOR EACH ROW EXECUTE PROCEDURE fabric_delete_notify();


--
-- Name: fabric_fabric_machine_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER fabric_fabric_machine_update_notify AFTER UPDATE ON maasserver_fabric FOR EACH ROW EXECUTE PROCEDURE fabric_machine_update_notify();


--
-- Name: fabric_fabric_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER fabric_fabric_update_notify AFTER UPDATE ON maasserver_fabric FOR EACH ROW EXECUTE PROCEDURE fabric_update_notify();


--
-- Name: filesystem_nd_filesystem_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER filesystem_nd_filesystem_link_notify AFTER INSERT ON maasserver_filesystem FOR EACH ROW EXECUTE PROCEDURE nd_filesystem_link_notify();


--
-- Name: filesystem_nd_filesystem_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER filesystem_nd_filesystem_unlink_notify AFTER DELETE ON maasserver_filesystem FOR EACH ROW EXECUTE PROCEDURE nd_filesystem_unlink_notify();


--
-- Name: filesystem_nd_filesystem_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER filesystem_nd_filesystem_update_notify AFTER UPDATE ON maasserver_filesystem FOR EACH ROW EXECUTE PROCEDURE nd_filesystem_update_notify();


--
-- Name: filesystemgroup_nd_filesystemgroup_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER filesystemgroup_nd_filesystemgroup_link_notify AFTER INSERT ON maasserver_filesystemgroup FOR EACH ROW EXECUTE PROCEDURE nd_filesystemgroup_link_notify();


--
-- Name: filesystemgroup_nd_filesystemgroup_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER filesystemgroup_nd_filesystemgroup_unlink_notify AFTER DELETE ON maasserver_filesystemgroup FOR EACH ROW EXECUTE PROCEDURE nd_filesystemgroup_unlink_notify();


--
-- Name: filesystemgroup_nd_filesystemgroup_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER filesystemgroup_nd_filesystemgroup_update_notify AFTER UPDATE ON maasserver_filesystemgroup FOR EACH ROW EXECUTE PROCEDURE nd_filesystemgroup_update_notify();


--
-- Name: interface_ip_addresses_nd_sipaddress_dns_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_ip_addresses_nd_sipaddress_dns_link_notify AFTER INSERT ON maasserver_interface_ip_addresses FOR EACH ROW EXECUTE PROCEDURE nd_sipaddress_dns_link_notify();


--
-- Name: interface_ip_addresses_nd_sipaddress_dns_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_ip_addresses_nd_sipaddress_dns_unlink_notify AFTER DELETE ON maasserver_interface_ip_addresses FOR EACH ROW EXECUTE PROCEDURE nd_sipaddress_dns_unlink_notify();


--
-- Name: interface_ip_addresses_nd_sipaddress_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_ip_addresses_nd_sipaddress_link_notify AFTER INSERT ON maasserver_interface_ip_addresses FOR EACH ROW EXECUTE PROCEDURE nd_sipaddress_link_notify();


--
-- Name: interface_ip_addresses_nd_sipaddress_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_ip_addresses_nd_sipaddress_unlink_notify AFTER DELETE ON maasserver_interface_ip_addresses FOR EACH ROW EXECUTE PROCEDURE nd_sipaddress_unlink_notify();


--
-- Name: interface_ip_addresses_sys_dns_nic_ip_link; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_ip_addresses_sys_dns_nic_ip_link AFTER INSERT ON maasserver_interface_ip_addresses FOR EACH ROW EXECUTE PROCEDURE sys_dns_nic_ip_link();


--
-- Name: interface_ip_addresses_sys_dns_nic_ip_unlink; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_ip_addresses_sys_dns_nic_ip_unlink AFTER DELETE ON maasserver_interface_ip_addresses FOR EACH ROW EXECUTE PROCEDURE sys_dns_nic_ip_unlink();


--
-- Name: interface_nd_interface_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_nd_interface_link_notify AFTER INSERT ON maasserver_interface FOR EACH ROW EXECUTE PROCEDURE nd_interface_link_notify();


--
-- Name: interface_nd_interface_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_nd_interface_unlink_notify AFTER DELETE ON maasserver_interface FOR EACH ROW EXECUTE PROCEDURE nd_interface_unlink_notify();


--
-- Name: interface_nd_interface_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_nd_interface_update_notify AFTER UPDATE ON maasserver_interface FOR EACH ROW EXECUTE PROCEDURE nd_interface_update_notify();


--
-- Name: interface_sys_dhcp_interface_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_sys_dhcp_interface_update AFTER UPDATE ON maasserver_interface FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_interface_update();


--
-- Name: interface_sys_dns_interface_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER interface_sys_dns_interface_update AFTER UPDATE ON maasserver_interface FOR EACH ROW EXECUTE PROCEDURE sys_dns_interface_update();


--
-- Name: iprange_iprange_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_iprange_create_notify AFTER INSERT ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE iprange_create_notify();


--
-- Name: iprange_iprange_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_iprange_delete_notify AFTER DELETE ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE iprange_delete_notify();


--
-- Name: iprange_iprange_subnet_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_iprange_subnet_delete_notify AFTER DELETE ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE iprange_subnet_delete_notify();


--
-- Name: iprange_iprange_subnet_insert_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_iprange_subnet_insert_notify AFTER INSERT ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE iprange_subnet_insert_notify();


--
-- Name: iprange_iprange_subnet_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_iprange_subnet_update_notify AFTER UPDATE ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE iprange_subnet_update_notify();


--
-- Name: iprange_iprange_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_iprange_update_notify AFTER UPDATE ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE iprange_update_notify();


--
-- Name: iprange_sys_dhcp_iprange_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_sys_dhcp_iprange_delete AFTER DELETE ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_iprange_delete();


--
-- Name: iprange_sys_dhcp_iprange_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_sys_dhcp_iprange_insert AFTER INSERT ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_iprange_insert();


--
-- Name: iprange_sys_dhcp_iprange_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER iprange_sys_dhcp_iprange_update AFTER UPDATE ON maasserver_iprange FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_iprange_update();


--
-- Name: metadataserver_noderesult_nd_noderesult_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER metadataserver_noderesult_nd_noderesult_link_notify AFTER INSERT ON metadataserver_noderesult FOR EACH ROW EXECUTE PROCEDURE nd_noderesult_link_notify();


--
-- Name: metadataserver_noderesult_nd_noderesult_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER metadataserver_noderesult_nd_noderesult_unlink_notify AFTER DELETE ON metadataserver_noderesult FOR EACH ROW EXECUTE PROCEDURE nd_noderesult_unlink_notify();


--
-- Name: neighbour_neighbour_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER neighbour_neighbour_create_notify AFTER INSERT ON maasserver_neighbour FOR EACH ROW EXECUTE PROCEDURE neighbour_create_notify();


--
-- Name: neighbour_neighbour_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER neighbour_neighbour_delete_notify AFTER DELETE ON maasserver_neighbour FOR EACH ROW EXECUTE PROCEDURE neighbour_delete_notify();


--
-- Name: neighbour_neighbour_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER neighbour_neighbour_update_notify AFTER UPDATE ON maasserver_neighbour FOR EACH ROW EXECUTE PROCEDURE neighbour_update_notify();


--
-- Name: node_device_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_device_create_notify AFTER INSERT ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 1)) EXECUTE PROCEDURE device_create_notify();


--
-- Name: node_device_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_device_delete_notify AFTER DELETE ON maasserver_node FOR EACH ROW WHEN ((old.node_type = 1)) EXECUTE PROCEDURE device_delete_notify();


--
-- Name: node_device_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_device_update_notify AFTER UPDATE ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 1)) EXECUTE PROCEDURE device_update_notify();


--
-- Name: node_machine_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_machine_create_notify AFTER INSERT ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 0)) EXECUTE PROCEDURE machine_create_notify();


--
-- Name: node_machine_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_machine_delete_notify AFTER DELETE ON maasserver_node FOR EACH ROW WHEN ((old.node_type = 0)) EXECUTE PROCEDURE machine_delete_notify();


--
-- Name: node_machine_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_machine_update_notify AFTER UPDATE ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 0)) EXECUTE PROCEDURE machine_update_notify();


--
-- Name: node_node_type_change_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_node_type_change_notify AFTER UPDATE ON maasserver_node FOR EACH ROW EXECUTE PROCEDURE node_type_change_notify();


--
-- Name: node_rack_controller_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_rack_controller_create_notify AFTER INSERT ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 2)) EXECUTE PROCEDURE rack_controller_create_notify();


--
-- Name: node_rack_controller_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_rack_controller_delete_notify AFTER DELETE ON maasserver_node FOR EACH ROW WHEN ((old.node_type = 2)) EXECUTE PROCEDURE rack_controller_delete_notify();


--
-- Name: node_rack_controller_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_rack_controller_update_notify AFTER UPDATE ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 2)) EXECUTE PROCEDURE rack_controller_update_notify();


--
-- Name: node_region_and_rack_controller_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_region_and_rack_controller_create_notify AFTER INSERT ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 4)) EXECUTE PROCEDURE region_and_rack_controller_create_notify();


--
-- Name: node_region_and_rack_controller_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_region_and_rack_controller_delete_notify AFTER DELETE ON maasserver_node FOR EACH ROW WHEN ((old.node_type = 4)) EXECUTE PROCEDURE region_and_rack_controller_delete_notify();


--
-- Name: node_region_and_rack_controller_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_region_and_rack_controller_update_notify AFTER UPDATE ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 4)) EXECUTE PROCEDURE region_and_rack_controller_update_notify();


--
-- Name: node_region_controller_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_region_controller_create_notify AFTER INSERT ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 3)) EXECUTE PROCEDURE region_controller_create_notify();


--
-- Name: node_region_controller_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_region_controller_delete_notify AFTER DELETE ON maasserver_node FOR EACH ROW WHEN ((old.node_type = 3)) EXECUTE PROCEDURE region_controller_delete_notify();


--
-- Name: node_region_controller_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_region_controller_update_notify AFTER UPDATE ON maasserver_node FOR EACH ROW WHEN ((new.node_type = 3)) EXECUTE PROCEDURE region_controller_update_notify();


--
-- Name: node_sys_dhcp_node_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_sys_dhcp_node_update AFTER UPDATE ON maasserver_node FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_node_update();


--
-- Name: node_sys_dns_node_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_sys_dns_node_delete AFTER DELETE ON maasserver_node FOR EACH ROW EXECUTE PROCEDURE sys_dns_node_delete();


--
-- Name: node_sys_dns_node_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_sys_dns_node_update AFTER UPDATE ON maasserver_node FOR EACH ROW EXECUTE PROCEDURE sys_dns_node_update();


--
-- Name: node_tags_machine_device_tag_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_tags_machine_device_tag_link_notify AFTER INSERT ON maasserver_node_tags FOR EACH ROW EXECUTE PROCEDURE machine_device_tag_link_notify();


--
-- Name: node_tags_machine_device_tag_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER node_tags_machine_device_tag_unlink_notify AFTER DELETE ON maasserver_node_tags FOR EACH ROW EXECUTE PROCEDURE machine_device_tag_unlink_notify();


--
-- Name: packagerepository_packagerepository_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER packagerepository_packagerepository_create_notify AFTER INSERT ON maasserver_packagerepository FOR EACH ROW EXECUTE PROCEDURE packagerepository_create_notify();


--
-- Name: packagerepository_packagerepository_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER packagerepository_packagerepository_delete_notify AFTER DELETE ON maasserver_packagerepository FOR EACH ROW EXECUTE PROCEDURE packagerepository_delete_notify();


--
-- Name: packagerepository_packagerepository_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER packagerepository_packagerepository_update_notify AFTER UPDATE ON maasserver_packagerepository FOR EACH ROW EXECUTE PROCEDURE packagerepository_update_notify();


--
-- Name: partition_nd_partition_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER partition_nd_partition_link_notify AFTER INSERT ON maasserver_partition FOR EACH ROW EXECUTE PROCEDURE nd_partition_link_notify();


--
-- Name: partition_nd_partition_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER partition_nd_partition_unlink_notify AFTER DELETE ON maasserver_partition FOR EACH ROW EXECUTE PROCEDURE nd_partition_unlink_notify();


--
-- Name: partition_nd_partition_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER partition_nd_partition_update_notify AFTER UPDATE ON maasserver_partition FOR EACH ROW EXECUTE PROCEDURE nd_partition_update_notify();


--
-- Name: partitiontable_nd_partitiontable_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER partitiontable_nd_partitiontable_link_notify AFTER INSERT ON maasserver_partitiontable FOR EACH ROW EXECUTE PROCEDURE nd_partitiontable_link_notify();


--
-- Name: partitiontable_nd_partitiontable_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER partitiontable_nd_partitiontable_unlink_notify AFTER DELETE ON maasserver_partitiontable FOR EACH ROW EXECUTE PROCEDURE nd_partitiontable_unlink_notify();


--
-- Name: partitiontable_nd_partitiontable_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER partitiontable_nd_partitiontable_update_notify AFTER UPDATE ON maasserver_partitiontable FOR EACH ROW EXECUTE PROCEDURE nd_partitiontable_update_notify();


--
-- Name: physicalblockdevice_nd_physblockdevice_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER physicalblockdevice_nd_physblockdevice_update_notify AFTER UPDATE ON maasserver_physicalblockdevice FOR EACH ROW EXECUTE PROCEDURE nd_physblockdevice_update_notify();


--
-- Name: regionrackrpcconnection_sys_core_rpc_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER regionrackrpcconnection_sys_core_rpc_delete AFTER DELETE ON maasserver_regionrackrpcconnection FOR EACH ROW EXECUTE PROCEDURE sys_core_rpc_delete();


--
-- Name: regionrackrpcconnection_sys_core_rpc_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER regionrackrpcconnection_sys_core_rpc_insert AFTER INSERT ON maasserver_regionrackrpcconnection FOR EACH ROW EXECUTE PROCEDURE sys_core_rpc_insert();


--
-- Name: service_service_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER service_service_create_notify AFTER INSERT ON maasserver_service FOR EACH ROW EXECUTE PROCEDURE service_create_notify();


--
-- Name: service_service_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER service_service_delete_notify AFTER DELETE ON maasserver_service FOR EACH ROW EXECUTE PROCEDURE service_delete_notify();


--
-- Name: service_service_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER service_service_update_notify AFTER UPDATE ON maasserver_service FOR EACH ROW EXECUTE PROCEDURE service_update_notify();


--
-- Name: space_space_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER space_space_create_notify AFTER INSERT ON maasserver_space FOR EACH ROW EXECUTE PROCEDURE space_create_notify();


--
-- Name: space_space_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER space_space_delete_notify AFTER DELETE ON maasserver_space FOR EACH ROW EXECUTE PROCEDURE space_delete_notify();


--
-- Name: space_space_machine_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER space_space_machine_update_notify AFTER UPDATE ON maasserver_space FOR EACH ROW EXECUTE PROCEDURE space_machine_update_notify();


--
-- Name: space_space_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER space_space_update_notify AFTER UPDATE ON maasserver_space FOR EACH ROW EXECUTE PROCEDURE space_update_notify();


--
-- Name: sshkey_sshkey_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sshkey_sshkey_create_notify AFTER INSERT ON maasserver_sshkey FOR EACH ROW EXECUTE PROCEDURE sshkey_create_notify();


--
-- Name: sshkey_sshkey_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sshkey_sshkey_delete_notify AFTER DELETE ON maasserver_sshkey FOR EACH ROW EXECUTE PROCEDURE sshkey_delete_notify();


--
-- Name: sshkey_sshkey_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sshkey_sshkey_update_notify AFTER UPDATE ON maasserver_sshkey FOR EACH ROW EXECUTE PROCEDURE sshkey_update_notify();


--
-- Name: sshkey_user_sshkey_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sshkey_user_sshkey_link_notify AFTER INSERT ON maasserver_sshkey FOR EACH ROW EXECUTE PROCEDURE user_sshkey_link_notify();


--
-- Name: sshkey_user_sshkey_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sshkey_user_sshkey_unlink_notify AFTER DELETE ON maasserver_sshkey FOR EACH ROW EXECUTE PROCEDURE user_sshkey_unlink_notify();


--
-- Name: sslkey_user_sslkey_link_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sslkey_user_sslkey_link_notify AFTER INSERT ON maasserver_sslkey FOR EACH ROW EXECUTE PROCEDURE user_sslkey_link_notify();


--
-- Name: sslkey_user_sslkey_unlink_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER sslkey_user_sslkey_unlink_notify AFTER DELETE ON maasserver_sslkey FOR EACH ROW EXECUTE PROCEDURE user_sslkey_unlink_notify();


--
-- Name: staticipaddress_ipaddress_domain_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_ipaddress_domain_delete_notify AFTER DELETE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE ipaddress_domain_delete_notify();


--
-- Name: staticipaddress_ipaddress_domain_insert_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_ipaddress_domain_insert_notify AFTER INSERT ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE ipaddress_domain_insert_notify();


--
-- Name: staticipaddress_ipaddress_domain_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_ipaddress_domain_update_notify AFTER UPDATE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE ipaddress_domain_update_notify();


--
-- Name: staticipaddress_ipaddress_machine_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_ipaddress_machine_update_notify AFTER UPDATE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE ipaddress_machine_update_notify();


--
-- Name: staticipaddress_ipaddress_subnet_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_ipaddress_subnet_update_notify AFTER UPDATE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE ipaddress_subnet_update_notify();


--
-- Name: staticipaddress_sys_dhcp_staticipaddress_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_sys_dhcp_staticipaddress_delete AFTER DELETE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_staticipaddress_delete();


--
-- Name: staticipaddress_sys_dhcp_staticipaddress_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_sys_dhcp_staticipaddress_insert AFTER INSERT ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_staticipaddress_insert();


--
-- Name: staticipaddress_sys_dhcp_staticipaddress_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_sys_dhcp_staticipaddress_update AFTER UPDATE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_staticipaddress_update();


--
-- Name: staticipaddress_sys_dns_staticipaddress_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticipaddress_sys_dns_staticipaddress_update AFTER UPDATE ON maasserver_staticipaddress FOR EACH ROW EXECUTE PROCEDURE sys_dns_staticipaddress_update();


--
-- Name: staticroute_staticroute_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticroute_staticroute_create_notify AFTER INSERT ON maasserver_staticroute FOR EACH ROW EXECUTE PROCEDURE staticroute_create_notify();


--
-- Name: staticroute_staticroute_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticroute_staticroute_delete_notify AFTER DELETE ON maasserver_staticroute FOR EACH ROW EXECUTE PROCEDURE staticroute_delete_notify();


--
-- Name: staticroute_staticroute_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER staticroute_staticroute_update_notify AFTER UPDATE ON maasserver_staticroute FOR EACH ROW EXECUTE PROCEDURE staticroute_update_notify();


--
-- Name: subnet_subnet_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_subnet_create_notify AFTER INSERT ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE subnet_create_notify();


--
-- Name: subnet_subnet_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_subnet_delete_notify AFTER DELETE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE subnet_delete_notify();


--
-- Name: subnet_subnet_machine_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_subnet_machine_update_notify AFTER UPDATE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE subnet_machine_update_notify();


--
-- Name: subnet_subnet_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_subnet_update_notify AFTER UPDATE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE subnet_update_notify();


--
-- Name: subnet_sys_dhcp_subnet_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_dhcp_subnet_delete AFTER DELETE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_subnet_delete();


--
-- Name: subnet_sys_dhcp_subnet_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_dhcp_subnet_update AFTER UPDATE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_subnet_update();


--
-- Name: subnet_sys_dns_subnet_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_dns_subnet_delete AFTER DELETE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_dns_subnet_delete();


--
-- Name: subnet_sys_dns_subnet_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_dns_subnet_insert AFTER INSERT ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_dns_subnet_insert();


--
-- Name: subnet_sys_dns_subnet_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_dns_subnet_update AFTER UPDATE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_dns_subnet_update();


--
-- Name: subnet_sys_proxy_subnet_delete; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_proxy_subnet_delete AFTER DELETE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_proxy_subnet_delete();


--
-- Name: subnet_sys_proxy_subnet_insert; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_proxy_subnet_insert AFTER INSERT ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_proxy_subnet_insert();


--
-- Name: subnet_sys_proxy_subnet_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER subnet_sys_proxy_subnet_update AFTER UPDATE ON maasserver_subnet FOR EACH ROW EXECUTE PROCEDURE sys_proxy_subnet_update();


--
-- Name: tag_tag_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER tag_tag_create_notify AFTER INSERT ON maasserver_tag FOR EACH ROW EXECUTE PROCEDURE tag_create_notify();


--
-- Name: tag_tag_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER tag_tag_delete_notify AFTER DELETE ON maasserver_tag FOR EACH ROW EXECUTE PROCEDURE tag_delete_notify();


--
-- Name: tag_tag_update_machine_device_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER tag_tag_update_machine_device_notify AFTER UPDATE ON maasserver_tag FOR EACH ROW EXECUTE PROCEDURE tag_update_machine_device_notify();


--
-- Name: tag_tag_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER tag_tag_update_notify AFTER UPDATE ON maasserver_tag FOR EACH ROW EXECUTE PROCEDURE tag_update_notify();


--
-- Name: virtualblockdevice_nd_virtblockdevice_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER virtualblockdevice_nd_virtblockdevice_update_notify AFTER UPDATE ON maasserver_virtualblockdevice FOR EACH ROW EXECUTE PROCEDURE nd_virtblockdevice_update_notify();


--
-- Name: vlan_sys_dhcp_vlan_update; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER vlan_sys_dhcp_vlan_update AFTER UPDATE ON maasserver_vlan FOR EACH ROW EXECUTE PROCEDURE sys_dhcp_vlan_update();


--
-- Name: vlan_vlan_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER vlan_vlan_create_notify AFTER INSERT ON maasserver_vlan FOR EACH ROW EXECUTE PROCEDURE vlan_create_notify();


--
-- Name: vlan_vlan_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER vlan_vlan_delete_notify AFTER DELETE ON maasserver_vlan FOR EACH ROW EXECUTE PROCEDURE vlan_delete_notify();


--
-- Name: vlan_vlan_machine_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER vlan_vlan_machine_update_notify AFTER UPDATE ON maasserver_vlan FOR EACH ROW EXECUTE PROCEDURE vlan_machine_update_notify();


--
-- Name: vlan_vlan_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER vlan_vlan_update_notify AFTER UPDATE ON maasserver_vlan FOR EACH ROW EXECUTE PROCEDURE vlan_update_notify();


--
-- Name: zone_zone_create_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER zone_zone_create_notify AFTER INSERT ON maasserver_zone FOR EACH ROW EXECUTE PROCEDURE zone_create_notify();


--
-- Name: zone_zone_delete_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER zone_zone_delete_notify AFTER DELETE ON maasserver_zone FOR EACH ROW EXECUTE PROCEDURE zone_delete_notify();


--
-- Name: zone_zone_update_notify; Type: TRIGGER; Schema: public; Owner: gavin
--

CREATE TRIGGER zone_zone_update_notify AFTER UPDATE ON maasserver_zone FOR EACH ROW EXECUTE PROCEDURE zone_update_notify();


--
-- Name: D0c860d9f861688ab58521589bd10163; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regionrackrpcconnection
    ADD CONSTRAINT "D0c860d9f861688ab58521589bd10163" FOREIGN KEY (endpoint_id) REFERENCES maasserver_regioncontrollerprocessendpoint(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D61bd7e2e01b3bc7060577e5a2e727b3; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT "D61bd7e2e01b3bc7060577e5a2e727b3" FOREIGN KEY (dns_process_id) REFERENCES maasserver_regioncontrollerprocess(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D645a9997a0b5c48b4bc64035dcbf873; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_virtualblockdevice
    ADD CONSTRAINT "D645a9997a0b5c48b4bc64035dcbf873" FOREIGN KEY (filesystem_group_id) REFERENCES maasserver_filesystemgroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D6c2daa68f0d441787deb6663abc368a; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT "D6c2daa68f0d441787deb6663abc368a" FOREIGN KEY (managing_process_id) REFERENCES maasserver_regioncontrollerprocess(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D6d8470a33b91721aaae1b5f16ff92ef; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface_ip_addresses
    ADD CONSTRAINT "D6d8470a33b91721aaae1b5f16ff92ef" FOREIGN KEY (staticipaddress_id) REFERENCES maasserver_staticipaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D6f0a412f4d5a348c545b72b0df82e88; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT "D6f0a412f4d5a348c545b72b0df82e88" FOREIGN KEY (boot_disk_id) REFERENCES maasserver_physicalblockdevice(blockdevice_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D7296a3abfc63731d67b804463b8c482; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourcefile
    ADD CONSTRAINT "D7296a3abfc63731d67b804463b8c482" FOREIGN KEY (resource_set_id) REFERENCES maasserver_bootresourceset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D7e0f230adc8d029ef0480007e7f6c53; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_virtualblockdevice
    ADD CONSTRAINT "D7e0f230adc8d029ef0480007e7f6c53" FOREIGN KEY (blockdevice_ptr_id) REFERENCES maasserver_blockdevice(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: D8c7ecd1bc2d612d24f2a2283cddda3f; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_template
    ADD CONSTRAINT "D8c7ecd1bc2d612d24f2a2283cddda3f" FOREIGN KEY (default_version_id) REFERENCES maasserver_versionedtextfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: a5fea0f3d7ac672f4542009362dd5f2f; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_versionedtextfile
    ADD CONSTRAINT a5fea0f3d7ac672f4542009362dd5f2f FOREIGN KEY (previous_version_id) REFERENCES maasserver_versionedtextfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: afa3c81b5dfbda13fa93d1a479967708; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource_ip_addresses
    ADD CONSTRAINT afa3c81b5dfbda13fa93d1a479967708 FOREIGN KEY (staticipaddress_id) REFERENCES maasserver_staticipaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_content_type_id_337b5968c9128b60_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_content_type_id_337b5968c9128b60_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissio_group_id_4928a3cc000e7b56_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_group_id_4928a3cc000e7b56_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permission_id_3b4a2b786d598060_fk_auth_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permission_id_3b4a2b786d598060_fk_auth_permission_id FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user__permission_id_74964c1003954cf5_fk_auth_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user__permission_id_74964c1003954cf5_fk_auth_permission_id FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups_group_id_5914392734b295a0_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_5914392734b295a0_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups_user_id_748cd5fabeab74c9_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_748cd5fabeab74c9_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permiss_user_id_4ae2760fed2959fe_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permiss_user_id_4ae2760fed2959fe_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ba4f605f61dc0234ae93a184480aa452; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_physicalblockdevice
    ADD CONSTRAINT ba4f605f61dc0234ae93a184480aa452 FOREIGN KEY (blockdevice_ptr_id) REFERENCES maasserver_blockdevice(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: be53ca84d482d154753508dacee42d4f; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT be53ca84d482d154753508dacee42d4f FOREIGN KEY (gateway_link_ipv6_id) REFERENCES maasserver_staticipaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: c1a66fad1fb27691c0201fd2d822eb42; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocessendpoint
    ADD CONSTRAINT c1a66fad1fb27691c0201fd2d822eb42 FOREIGN KEY (process_id) REFERENCES maasserver_regioncontrollerprocess(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: d3b2f73b393b1199700c0fc234461aba; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT d3b2f73b393b1199700c0fc234461aba FOREIGN KEY (filesystem_group_id) REFERENCES maasserver_filesystemgroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: e0f1a14a92b8a49cf947782be9f10c01; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT e0f1a14a92b8a49cf947782be9f10c01 FOREIGN KEY (gateway_link_ipv4_id) REFERENCES maasserver_staticipaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: fb0f13adafff821420f598d3c9263ccc; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partition
    ADD CONSTRAINT fb0f13adafff821420f598d3c9263ccc FOREIGN KEY (partition_table_id) REFERENCES maasserver_partitiontable(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ip_address_id_a21bdcdbc35de76_fk_maasserver_staticipaddress_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmc
    ADD CONSTRAINT ip_address_id_a21bdcdbc35de76_fk_maasserver_staticipaddress_id FOREIGN KEY (ip_address_id) REFERENCES maasserver_staticipaddress(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: m_block_device_id_5d40327628f982fd_fk_maasserver_blockdevice_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_partitiontable
    ADD CONSTRAINT m_block_device_id_5d40327628f982fd_fk_maasserver_blockdevice_id FOREIGN KEY (block_device_id) REFERENCES maasserver_blockdevice(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: m_block_device_id_6ca31dd785924cb2_fk_maasserver_blockdevice_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT m_block_device_id_6ca31dd785924cb2_fk_maasserver_blockdevice_id FOREIGN KEY (block_device_id) REFERENCES maasserver_blockdevice(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: m_boot_interface_id_31e2c37aabfa540f_fk_maasserver_interface_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT m_boot_interface_id_31e2c37aabfa540f_fk_maasserver_interface_id FOREIGN KEY (boot_interface_id) REFERENCES maasserver_interface(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ma_dnsresource_id_3e5f04e245ca349c_fk_maasserver_dnsresource_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsdata
    ADD CONSTRAINT ma_dnsresource_id_3e5f04e245ca349c_fk_maasserver_dnsresource_id FOREIGN KEY (dnsresource_id) REFERENCES maasserver_dnsresource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ma_dnsresource_id_45ba7b313e98fa4f_fk_maasserver_dnsresource_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource_ip_addresses
    ADD CONSTRAINT ma_dnsresource_id_45ba7b313e98fa4f_fk_maasserver_dnsresource_id FOREIGN KEY (dnsresource_id) REFERENCES maasserver_dnsresource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ma_value_id_66a58274593e4e90_fk_maasserver_versionedtextfile_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dhcpsnippet
    ADD CONSTRAINT ma_value_id_66a58274593e4e90_fk_maasserver_versionedtextfile_id FOREIGN KEY (value_id) REFERENCES maasserver_versionedtextfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maa_boot_source_id_23177193e1638e6d_fk_maasserver_bootsource_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourcecache
    ADD CONSTRAINT maa_boot_source_id_23177193e1638e6d_fk_maasserver_bootsource_id FOREIGN KEY (boot_source_id) REFERENCES maasserver_bootsource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maa_boot_source_id_23f7dca79bddebc1_fk_maasserver_bootsource_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootsourceselection
    ADD CONSTRAINT maa_boot_source_id_23f7dca79bddebc1_fk_maasserver_bootsource_id FOREIGN KEY (boot_source_id) REFERENCES maasserver_bootsource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maas_resource_id_2a3e892bdbd0a03a_fk_maasserver_bootresource_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourceset
    ADD CONSTRAINT maas_resource_id_2a3e892bdbd0a03a_fk_maasserver_bootresource_id FOREIGN KEY (resource_id) REFERENCES maasserver_bootresource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maass_rack_controller_id_511893fbda70e547_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regionrackrpcconnection
    ADD CONSTRAINT maass_rack_controller_id_511893fbda70e547_fk_maasserver_node_id FOREIGN KEY (rack_controller_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maass_rack_controller_id_631ace11a05889bc_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmcroutablerackcontrollerrelationship
    ADD CONSTRAINT maass_rack_controller_id_631ace11a05889bc_fk_maasserver_node_id FOREIGN KEY (rack_controller_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_interface_id_34690a6303e32fbe_fk_maasserver_interface_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_mdns
    ADD CONSTRAINT maasse_interface_id_34690a6303e32fbe_fk_maasserver_interface_id FOREIGN KEY (interface_id) REFERENCES maasserver_interface(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_interface_id_409a4ebec7a6e50d_fk_maasserver_interface_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface_ip_addresses
    ADD CONSTRAINT maasse_interface_id_409a4ebec7a6e50d_fk_maasserver_interface_id FOREIGN KEY (interface_id) REFERENCES maasserver_interface(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_interface_id_42a98cb34e89f912_fk_maasserver_interface_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_neighbour
    ADD CONSTRAINT maasse_interface_id_42a98cb34e89f912_fk_maasserver_interface_id FOREIGN KEY (interface_id) REFERENCES maasserver_interface(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_keysource_id_4e86b9c4fb175707_fk_maasserver_keysource_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sshkey
    ADD CONSTRAINT maasse_keysource_id_4e86b9c4fb175707_fk_maasserver_keysource_id FOREIGN KEY (keysource_id) REFERENCES maasserver_keysource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_largefile_id_768396ab6ba9a51f_fk_maasserver_largefile_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bootresourcefile
    ADD CONSTRAINT maasse_largefile_id_768396ab6ba9a51f_fk_maasserver_largefile_id FOREIGN KEY (largefile_id) REFERENCES maasserver_largefile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_partition_id_68e66caa10f0b3b5_fk_maasserver_partition_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT maasse_partition_id_68e66caa10f0b3b5_fk_maasserver_partition_id FOREIGN KEY (partition_id) REFERENCES maasserver_partition(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasse_secondary_rack_id_64720a7561c82614_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasse_secondary_rack_id_64720a7561c82614_fk_maasserver_node_id FOREIGN KEY (secondary_rack_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasser_cache_set_id_65a66fc4a8ecab49_fk_maasserver_cacheset_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT maasser_cache_set_id_65a66fc4a8ecab49_fk_maasserver_cacheset_id FOREIGN KEY (cache_set_id) REFERENCES maasserver_cacheset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasser_destination_id_7846591d5f7b863e_fk_maasserver_subnet_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticroute
    ADD CONSTRAINT maasser_destination_id_7846591d5f7b863e_fk_maasserver_subnet_id FOREIGN KEY (destination_id) REFERENCES maasserver_subnet(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserv_cache_set_id_d05da9a7e916c35_fk_maasserver_cacheset_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystemgroup
    ADD CONSTRAINT maasserv_cache_set_id_d05da9a7e916c35_fk_maasserver_cacheset_id FOREIGN KEY (cache_set_id) REFERENCES maasserver_cacheset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserv_primary_rack_id_6755be4f4cef2c07_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasserv_primary_rack_id_6755be4f4cef2c07_fk_maasserver_node_id FOREIGN KEY (primary_rack_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserve_parent_id_1d60ba3c504831dd_fk_maasserver_interface_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interfacerelationship
    ADD CONSTRAINT maasserve_parent_id_1d60ba3c504831dd_fk_maasserver_interface_id FOREIGN KEY (parent_id) REFERENCES maasserver_interface(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver__type_id_225b2e11c0021836_fk_maasserver_eventtype_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_event
    ADD CONSTRAINT maasserver__type_id_225b2e11c0021836_fk_maasserver_eventtype_id FOREIGN KEY (type_id) REFERENCES maasserver_eventtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_blockd_node_id_3950b3a1aa617ec_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_blockdevice
    ADD CONSTRAINT maasserver_blockd_node_id_3950b3a1aa617ec_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_bmcrout_bmc_id_343ebcced23e36ca_fk_maasserver_bmc_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_bmcroutablerackcontrollerrelationship
    ADD CONSTRAINT maasserver_bmcrout_bmc_id_343ebcced23e36ca_fk_maasserver_bmc_id FOREIGN KEY (bmc_id) REFERENCES maasserver_bmc(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_ch_chassis_id_3bfe88cf6898e543_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_chassishints
    ADD CONSTRAINT maasserver_ch_chassis_id_3bfe88cf6898e543_fk_maasserver_node_id FOREIGN KEY (chassis_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_child_id_13c522e75bf8a36c_fk_maasserver_interface_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interfacerelationship
    ADD CONSTRAINT maasserver_child_id_13c522e75bf8a36c_fk_maasserver_interface_id FOREIGN KEY (child_id) REFERENCES maasserver_interface(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_d_subnet_id_6a238431ebaecda1_fk_maasserver_subnet_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dhcpsnippet
    ADD CONSTRAINT maasserver_d_subnet_id_6a238431ebaecda1_fk_maasserver_subnet_id FOREIGN KEY (subnet_id) REFERENCES maasserver_subnet(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_dhcps_node_id_38b511f3283864c3_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dhcpsnippet
    ADD CONSTRAINT maasserver_dhcps_node_id_38b511f3283864c3_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_dn_domain_id_c547b56c76236eb_fk_maasserver_domain_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_dnsresource
    ADD CONSTRAINT maasserver_dn_domain_id_c547b56c76236eb_fk_maasserver_domain_id FOREIGN KEY (domain_id) REFERENCES maasserver_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_event_node_id_6a0f756187300c50_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_event
    ADD CONSTRAINT maasserver_event_node_id_6a0f756187300c50_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_files_node_id_3925c2a5df83468d_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filesystem
    ADD CONSTRAINT maasserver_files_node_id_3925c2a5df83468d_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_filestorage_owner_id_7ef72a05f519a6a_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_filestorage
    ADD CONSTRAINT maasserver_filestorage_owner_id_7ef72a05f519a6a_fk_auth_user_id FOREIGN KEY (owner_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_i_subnet_id_4318ea0fd006f409_fk_maasserver_subnet_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_iprange
    ADD CONSTRAINT maasserver_i_subnet_id_4318ea0fd006f409_fk_maasserver_subnet_id FOREIGN KEY (subnet_id) REFERENCES maasserver_subnet(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_interf_node_id_a667577d5e2a16b_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface
    ADD CONSTRAINT maasserver_interf_node_id_a667577d5e2a16b_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_interf_vlan_id_d5eb7d12672f81c_fk_maasserver_vlan_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_interface
    ADD CONSTRAINT maasserver_interf_vlan_id_d5eb7d12672f81c_fk_maasserver_vlan_id FOREIGN KEY (vlan_id) REFERENCES maasserver_vlan(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_iprange_user_id_7a03a667cf626e4_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_iprange
    ADD CONSTRAINT maasserver_iprange_user_id_7a03a667cf626e4_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_n_domain_id_6d80cc59c764e2b0_fk_maasserver_domain_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_n_domain_id_6d80cc59c764e2b0_fk_maasserver_domain_id FOREIGN KEY (domain_id) REFERENCES maasserver_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_no_subnet_id_84adae57317570d_fk_maasserver_subnet_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_nodegrouptorackcontroller
    ADD CONSTRAINT maasserver_no_subnet_id_84adae57317570d_fk_maasserver_subnet_id FOREIGN KEY (subnet_id) REFERENCES maasserver_subnet(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node__node_id_6306a1eec930287e_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node_tags
    ADD CONSTRAINT maasserver_node__node_id_6306a1eec930287e_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node_bmc_id_7e4201fcd8f2ff7_fk_maasserver_bmc_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_bmc_id_7e4201fcd8f2ff7_fk_maasserver_bmc_id FOREIGN KEY (bmc_id) REFERENCES maasserver_bmc(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node_owner_id_576b8b7195b5a203_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_owner_id_576b8b7195b5a203_fk_auth_user_id FOREIGN KEY (owner_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node_parent_id_bbee30784db439e_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_parent_id_bbee30784db439e_fk_maasserver_node_id FOREIGN KEY (parent_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node_ta_tag_id_78f748ea842a95a1_fk_maasserver_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node_tags
    ADD CONSTRAINT maasserver_node_ta_tag_id_78f748ea842a95a1_fk_maasserver_tag_id FOREIGN KEY (tag_id) REFERENCES maasserver_tag(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node_token_id_603aaf520a3e8f9a_fk_piston3_token_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_token_id_603aaf520a3e8f9a_fk_piston3_token_id FOREIGN KEY (token_id) REFERENCES piston3_token(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_node_zone_id_fccde7ef417dfb3_fk_maasserver_zone_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_node
    ADD CONSTRAINT maasserver_node_zone_id_fccde7ef417dfb3_fk_maasserver_zone_id FOREIGN KEY (zone_id) REFERENCES maasserver_zone(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_notificatio_user_id_2fafb297b6ac5e46_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_notification
    ADD CONSTRAINT maasserver_notificatio_user_id_2fafb297b6ac5e46_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_owner_node_id_1333fe9c1398e937_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_ownerdata
    ADD CONSTRAINT maasserver_owner_node_id_1333fe9c1398e937_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_r_observer_id_206101b65f62ecc6_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_rdns
    ADD CONSTRAINT maasserver_r_observer_id_206101b65f62ecc6_fk_maasserver_node_id FOREIGN KEY (observer_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_reg_region_id_783c62c595f50325_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_regioncontrollerprocess
    ADD CONSTRAINT maasserver_reg_region_id_783c62c595f50325_fk_maasserver_node_id FOREIGN KEY (region_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_relay_vlan_id_1e9def96df6818e4_fk_maasserver_vlan_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasserver_relay_vlan_id_1e9def96df6818e4_fk_maasserver_vlan_id FOREIGN KEY (relay_vlan_id) REFERENCES maasserver_vlan(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_s_source_id_16f1baca36ac7e99_fk_maasserver_subnet_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticroute
    ADD CONSTRAINT maasserver_s_source_id_16f1baca36ac7e99_fk_maasserver_subnet_id FOREIGN KEY (source_id) REFERENCES maasserver_subnet(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_s_subnet_id_53f19683615ce07d_fk_maasserver_subnet_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticipaddress
    ADD CONSTRAINT maasserver_s_subnet_id_53f19683615ce07d_fk_maasserver_subnet_id FOREIGN KEY (subnet_id) REFERENCES maasserver_subnet(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_servi_node_id_3576432bac58bc26_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_service
    ADD CONSTRAINT maasserver_servi_node_id_3576432bac58bc26_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_sshkey_user_id_48232f291a28eae1_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sshkey
    ADD CONSTRAINT maasserver_sshkey_user_id_48232f291a28eae1_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_sslkey_user_id_3b4fb9ca0b43a44c_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_sslkey
    ADD CONSTRAINT maasserver_sslkey_user_id_3b4fb9ca0b43a44c_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_staticipadd_user_id_76908383c915ae70_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_staticipaddress
    ADD CONSTRAINT maasserver_staticipadd_user_id_76908383c915ae70_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_subne_vlan_id_1842fb41a7629aa8_fk_maasserver_vlan_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_subnet
    ADD CONSTRAINT maasserver_subne_vlan_id_1842fb41a7629aa8_fk_maasserver_vlan_id FOREIGN KEY (vlan_id) REFERENCES maasserver_vlan(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_userprofile_user_id_7efc8a6d9cd27b19_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_userprofile
    ADD CONSTRAINT maasserver_userprofile_user_id_7efc8a6d9cd27b19_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_v_fabric_id_30ea6db0631d8f27_fk_maasserver_fabric_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasserver_v_fabric_id_30ea6db0631d8f27_fk_maasserver_fabric_id FOREIGN KEY (fabric_id) REFERENCES maasserver_fabric(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: maasserver_vla_space_id_22bcdb56894e7fb1_fk_maasserver_space_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_vlan
    ADD CONSTRAINT maasserver_vla_space_id_22bcdb56894e7fb1_fk_maasserver_space_id FOREIGN KEY (space_id) REFERENCES maasserver_space(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: metadataserver_n_node_id_12e286210420719c_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodeuserdata
    ADD CONSTRAINT metadataserver_n_node_id_12e286210420719c_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: metadataserver_n_node_id_1c21bb65210d66d2_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey
    ADD CONSTRAINT metadataserver_n_node_id_1c21bb65210d66d2_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: metadataserver_n_node_id_2f46d8bcd1d9686b_fk_maasserver_node_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_noderesult
    ADD CONSTRAINT metadataserver_n_node_id_2f46d8bcd1d9686b_fk_maasserver_node_id FOREIGN KEY (node_id) REFERENCES maasserver_node(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: metadataserver_no_token_id_7436f04f01eec36d_fk_piston3_token_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY metadataserver_nodekey
    ADD CONSTRAINT metadataserver_no_token_id_7436f04f01eec36d_fk_piston3_token_id FOREIGN KEY (token_id) REFERENCES piston3_token(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: piston3_consumer_user_id_92495dcaa8baf2c_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_consumer
    ADD CONSTRAINT piston3_consumer_user_id_92495dcaa8baf2c_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: piston3_toke_consumer_id_6e45ea511fff007_fk_piston3_consumer_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_token
    ADD CONSTRAINT piston3_toke_consumer_id_6e45ea511fff007_fk_piston3_consumer_id FOREIGN KEY (consumer_id) REFERENCES piston3_consumer(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: piston3_token_user_id_fd889d0df8afc83_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY piston3_token
    ADD CONSTRAINT piston3_token_user_id_fd889d0df8afc83_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: version_id_485d366fd23da79b_fk_maasserver_versionedtextfile_id; Type: FK CONSTRAINT; Schema: public; Owner: gavin
--

ALTER TABLE ONLY maasserver_template
    ADD CONSTRAINT version_id_485d366fd23da79b_fk_maasserver_versionedtextfile_id FOREIGN KEY (version_id) REFERENCES maasserver_versionedtextfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: public; Type: ACL; Schema: -; Owner: gavin
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM gavin;
GRANT ALL ON SCHEMA public TO gavin;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

