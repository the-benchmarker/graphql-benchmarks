package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/graphql-go/graphql"
)

var likeCount = 0

func handleGraphQL(w http.ResponseWriter, req *http.Request, schema graphql.Schema) {
	var result *graphql.Result
	if req.Method == "GET" {
		result = graphql.Do(graphql.Params{
			Schema:        schema,
			RequestString: req.URL.Query().Get("query"),
		})
	} else {
		defer req.Body.Close()
		body, err := ioutil.ReadAll(req.Body)
		if err != nil {
			json.NewEncoder(w).Encode(err.Error())
			return
		}
		result = graphql.Do(graphql.Params{
			Schema:        schema,
			RequestString: string(body),
		})
	}
	json.NewEncoder(w).Encode(result)
}

func buildSchema() (graphql.Schema, error) {
	// type Query {
	//   hello(name: String!): String
	// }
	queryType := graphql.NewObject(graphql.ObjectConfig{
		Name: "Query",
		Fields: graphql.Fields{
			"hello": &graphql.Field{
				Type: graphql.String,
				Args: graphql.FieldConfigArgument{
					"name": &graphql.ArgumentConfig{
						Type: graphql.NewNonNull(graphql.String),
					},
				},
				Resolve: func(params graphql.ResolveParams) (interface{}, error) {
					name := params.Args["name"].(string)
					return "Hello " + name, nil
				},
			},
		},
	})
	// type Mutation {
	//   "Increment the like-count and return the new value."
	//   like: Int
	// }
	mutationType := graphql.NewObject(graphql.ObjectConfig{
		Name: "Mutation",
		Fields: graphql.Fields{
			"like": &graphql.Field{
				Type: graphql.Int,
				Resolve: func(params graphql.ResolveParams) (interface{}, error) {
					likeCount++
					return likeCount, nil
				},
			},
		},
	})
	// type schema {
	//   query: Query
	//   mutation: Mutation
	// }
	return graphql.NewSchema(graphql.SchemaConfig{
		Query:    queryType,
		Mutation: mutationType,
	})
}

func main() {
	schema, err := buildSchema()
	if err != nil {
		fmt.Printf("*-*-* Failed to build schema. %s\n", err)
		os.Exit(1)
	}
	http.HandleFunc("/graphql", func(w http.ResponseWriter, r *http.Request) {
		handleGraphQL(w, r, schema)
	})
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {})

	if err = http.ListenAndServe(":3000", nil); err != nil {
		fmt.Printf("*-*-* Server failed. %s\n", err)
	}
}
