// Copyright 2019 by Peter Ohler, All Rights Reserved

#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>

#define HAVE_STDATOMIC_H	1

#include <agoo.h>
#include <agoo/gqlintro.h>
#include <agoo/gqlvalue.h>
#include <agoo/graphql.h>
#include <agoo/log.h>
#include <agoo/page.h>
#include <agoo/res.h>
#include <agoo/sdl.h>
#include <agoo/server.h>

static agooText			emptyResp = NULL;
static atomic_int_fast64_t	like_count = 0;


static const char	*sdl = "\n\
type Query {\n\
  hello(name: String!): String\n\
}\n\
type Mutation {\n\
  \"Increment the like-count and return the new value.\"\n\
  like: Int\n\
}\n";

static void
empty_handler(agooReq req) {
    if (NULL == emptyResp) {
	emptyResp = agoo_respond(200, NULL, 0, NULL);
	agoo_text_ref(emptyResp);
    }
    agoo_res_set_message(req->res, emptyResp);
}

///// Query type setup

static int
query_hello(agooErr err, gqlDoc doc, gqlCobj obj, gqlField field, gqlSel sel, gqlValue result, int depth) {
    const char	*key = sel->name;
    char	hello[1024];
    int		len;
    gqlValue	val;
    gqlValue	nv = gql_extract_arg(err, field, sel, "name");
    const char	*name = NULL;

    if (NULL != nv) {
	name = gql_string_get(nv);
    }
    if (NULL == name) {
	name = "";
    }
    len = snprintf(hello, sizeof(hello), "Hello %s", name);
    val = gql_string_create(err, hello, len);

    if (NULL != sel->alias) {
	key = sel->alias;
    }
    return gql_object_set(err, result, key, val);
}

static struct _gqlCmethod	query_methods[] = {
    { .key = "hello", .func = query_hello },
    { .key = NULL,    .func = NULL },
};

static struct _gqlCclass	query_class = {
    .name = "query",
    .methods = query_methods,
};

static struct _gqlCobj	query_obj = {
    .clas = &query_class,
    .ptr = NULL,
};

///// Mutation type setup

static int
mutation_like(agooErr err, gqlDoc doc, gqlCobj obj, gqlField field, gqlSel sel, gqlValue result, int depth) {
    const char	*key = sel->name;
    gqlValue	val;
    int64_t	count = atomic_fetch_add(&like_count, 1);

    val = gql_int_create(err, (int)(count + 1));
    if (NULL != sel->alias) {
	key = sel->alias;
    }
    return gql_object_set(err, result, key, val);
}

static struct _gqlCmethod	mutation_methods[] = {
    { .key = "like", .func = mutation_like },
    { .key = NULL,     .func = NULL },
};

static struct _gqlCclass	mutation_class = {
    .name = "mutation",
    .methods = mutation_methods,
};

static struct _gqlCobj	mutation_obj = {
    .clas = &mutation_class,
    .ptr = NULL,
};

int
main(int argc, char **argv) {
    struct _agooErr	err = AGOO_ERR_INIT;
    int			port = 3000;

    atomic_init(&like_count, 0);

    agoo_io_loop_ratio = 0.6;   // higher values mean more IO threads
    if (AGOO_ERR_OK != agoo_init(&err, "simple")) {
	printf("Failed to initialize Agoo. %s\n", err.msg);
	return err.code;
    }
    agoo_server.thread_cnt = 1; // eval threads

    if (AGOO_ERR_OK != agoo_pages_set_root(&err, ".")) {
	printf("Failed to set root. %s\n", err.msg);
	return err.code;
    }
    if (AGOO_ERR_OK != agoo_bind_to_port(&err, port)) {
	printf("Failed to bind to port %d. %s\n", port, err.msg);
	return err.code;
    }
    if (AGOO_ERR_OK != agoo_setup_graphql(&err, "/graphql", sdl, NULL)) {
	return err.code;
    }
    agoo_query_object = &query_obj;
    agoo_mutation_object = &mutation_obj;

    // set up hooks or routes
    if (AGOO_ERR_OK != agoo_add_func_hook(&err, AGOO_GET, "/", empty_handler, true)) {
	return err.code;
    }
    // start the server and wait for it to be shutdown
    if (AGOO_ERR_OK != agoo_start(&err, AGOO_VERSION)) {
	printf("%s\n", err.msg);
	return err.code;
    }
    return 0;
}
