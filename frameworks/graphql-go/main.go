package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/graphql-go/graphql"
	"github.com/graphql-go/graphql/language/ast"
)

// Define the types and data in a generic way without considering the GraphQL
// package then hookup the package as needed. This section is copined into all
// golang framework applications.
func setup() *Schema {
	fazerdaze := Artist{Name: "Fazerdaze", Origin: []string{"Morningside", "Auckland", "New Zealand"}}
	may5 := &Date{Year: 2017, Month: 5, Day: 5}
	nov2 := &Date{Year: 2015, Month: 11, Day: 2}
	fazerdaze.Songs = map[string]*Song{
		"Jennifer":  {Name: "Jennifer", Artist: &fazerdaze, Duration: 240, Release: may5},
		"Luck Girl": {Name: "Luck Girl", Artist: &fazerdaze, Duration: 170, Release: may5},
		"Friends":   {Name: "Friends", Artist: &fazerdaze, Duration: 194, Release: may5},
		"Reel":      {Name: "Reel", Artist: &fazerdaze, Duration: 193, Release: nov2},
	}

	boys := Artist{Name: "Viagra Boys", Origin: []string{"Stockholm", "Sweden"}}
	sep28 := &Date{Year: 2018, Month: 11, Day: 2}
	boys.Songs = map[string]*Song{
		"Down In The Basement": {Name: "Down In The Basement", Artist: &boys, Duration: 216, Release: sep28},
		"Frogstrap":            {Name: "Frogstrap", Artist: &boys, Duration: 195, Release: sep28},
		"Worms":                {Name: "Worms", Artist: &boys, Duration: 208, Release: sep28},
		"Amphetanarchy":        {Name: "Amphetanarchy", Artist: &boys, Duration: 346, Release: sep28},
	}

	query := Query{
		Title:   "Songs",
		Artists: map[string]*Artist{fazerdaze.Name: &fazerdaze, boys.Name: &boys},
	}
	return &Schema{
		Query:    &query,
		Mutation: &Mutation{query: &query},
	}
}

type Schema struct {
	Query    *Query
	Mutation *Mutation
}

type Query struct {
	Title   string
	Artists map[string]*Artist
}

type Mutation struct {
	query *Query // Query is the data store for this example
}

func (m *Mutation) Like(artist, song string) *Song {
	if a := m.query.Artists[artist]; a != nil {
		if s := a.Songs[song]; s != nil {
			return s
		}
	}
	return nil
}

func (q *Query) Artist(name string) *Artist {
	return q.Artists[name]
}

type Artist struct {
	Name   string
	Songs  map[string]*Song
	Origin []string
}

type Song struct {
	Name     string
	Artist   *Artist
	Duration int
	Release  *Date
	Likes    int
}

type Date struct {
	Year  int
	Month int
	Day   int
}

func DateFromString(s string) (d *Date, err error) {
	d = &Date{}
	parts := strings.Split(s, "-")
	if len(parts) != 3 {
		return nil, fmt.Errorf("%s is not a valid date format", s)
	}
	if d.Year, err = strconv.Atoi(parts[0]); err == nil {
		if d.Month, err = strconv.Atoi(parts[1]); err == nil {
			d.Day, err = strconv.Atoi(parts[2])
		}
	}
	return
}

func (d *Date) String() string {
	return fmt.Sprintf("%04d-%02d-%02d", d.Year, d.Month, d.Day)
}

////////////////////////////////////////////////////////////////////////////////
// Now the framework specific code.

func (q *Query) ArtistsGG(params graphql.ResolveParams) (interface{}, error) {
	artists := make([]interface{}, 0, len(q.Artists))
	for _, a := range q.Artists {
		artists = append(artists, a)
	}
	return artists, nil
}

func (m *Mutation) LikeGG(params graphql.ResolveParams) (interface{}, error) {
	artist, ok := params.Args["artist"].(string)
	if !ok {
		return nil, fmt.Errorf("%v is not a valid artist. Must be a string",
			params.Args["artist"])
	}
	song, ok := params.Args["song"].(string)
	if !ok {
		return nil, fmt.Errorf("%v is not a valid song. Must be a string",
			params.Args["song"])
	}
	if a := m.query.Artists[artist]; a != nil {
		if s := a.Songs[song]; s != nil {
			s.Likes++
			return s, nil
		}
	}
	return nil, nil
}

func handleGraphQL(w http.ResponseWriter, req *http.Request, schema graphql.Schema) {
	var result *graphql.Result
	switch req.Method {
	case "GET":
		result = graphql.Do(graphql.Params{
			Schema:        schema,
			RequestString: req.URL.Query().Get("query"),
		})
	case "POST":
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

// graphql-go does not use functions on struct but just a function. The names
// in this example lend some organization to the the code.

func QueryArtist(params graphql.ResolveParams) (interface{}, error) {
	name, ok := params.Args["name"].(string)
	if !ok {
		return nil, fmt.Errorf("%v is not a valid name. Must be a string",
			params.Args["name"])
	}
	var q *Query
	if q, ok = params.Source.(*Query); !ok {
		return nil, fmt.Errorf("Schema.query resolve failed (%T)", params.Source)
	}
	return q.Artists[name], nil
}

func QueryArtists(params graphql.ResolveParams) (interface{}, error) {
	q, ok := params.Source.(*Query)
	if !ok {
		fmt.Printf("*** %v\n", params)
		return nil, fmt.Errorf("Schema.query resolve failed XX (%T)", params.Source)
	}
	artists := make([]interface{}, 0, len(q.Artists))
	for _, a := range q.Artists {
		artists = append(artists, a)
	}
	return artists, nil
}

func ArtistName(params graphql.ResolveParams) (interface{}, error) {
	a, ok := params.Source.(*Artist)
	if !ok {
		return nil, fmt.Errorf("Query.artist resolve failed (%T)", params.Source)
	}
	return a.Name, nil
}

func ArtistSong(params graphql.ResolveParams) (interface{}, error) {
	name, ok := params.Args["name"].(string)
	if !ok {
		return nil, fmt.Errorf("%v is not a valid name. Must be a string",
			params.Args["name"])
	}
	var a *Artist
	if a, ok = params.Source.(*Artist); !ok {
		return nil, fmt.Errorf("Query.artist resolve failed (%T)", params.Source)
	}
	return a.Songs[name], nil
}

func ArtistSongs(params graphql.ResolveParams) (interface{}, error) {
	a, ok := params.Source.(*Artist)
	if !ok {
		return nil, fmt.Errorf("Query.artist resolve failed (%T)", params.Source)
	}
	songs := make([]interface{}, 0, len(a.Songs))
	for _, s := range a.Songs {
		songs = append(songs, s)
	}
	return songs, nil
}

func SongName(params graphql.ResolveParams) (interface{}, error) {
	s, ok := params.Source.(*Song)
	if !ok {
		return nil, fmt.Errorf("Artist.song resolve failed (%T)", params.Source)
	}
	return s.Name, nil
}

func SongArtist(params graphql.ResolveParams) (interface{}, error) {
	s, ok := params.Source.(*Song)
	if !ok {
		return nil, fmt.Errorf("Artist.song resolve failed (%T)", params.Source)
	}
	return s.Artist, nil
}

func SongDuration(params graphql.ResolveParams) (interface{}, error) {
	s, ok := params.Source.(*Song)
	if !ok {
		return nil, fmt.Errorf("Artist.song resolve failed (%T)", params.Source)
	}
	return s.Duration, nil
}

func SongRelease(params graphql.ResolveParams) (interface{}, error) {
	s, ok := params.Source.(*Song)
	if !ok {
		return nil, fmt.Errorf("Artist.song resolve failed (%T)", params.Source)
	}
	return s.Release, nil
}

func SongLikes(params graphql.ResolveParams) (interface{}, error) {
	s, ok := params.Source.(*Song)
	if !ok {
		return nil, fmt.Errorf("Artist.song resolve failed (%T)", params.Source)
	}
	return s.Likes, nil
}

func DateSerialize(value interface{}) interface{} {
	d, ok := value.(*Date)
	if !ok {
		return nil
	}
	return d.String()
}

func DateParseValue(value interface{}) interface{} {
	s, ok := value.(string)
	if !ok {
		return nil
	}
	// No way to handle the error other than a panic so return nil.
	d, err := DateFromString(s)
	if err != nil {
		d = nil
	}
	return d
}

func DateParseLiteral(value ast.Value) interface{} {
	if vs, ok := value.(*ast.StringValue); ok {
		d, err := DateFromString(vs.Value)
		if err != nil {
			d = nil
		}
		return d
	}
	return nil
}

func buildSchema(data *Schema) (graphql.Schema, error) {

	// scalar Date
	dateType := graphql.NewScalar(graphql.ScalarConfig{
		Name:         "Date",
		Serialize:    DateSerialize,
		ParseValue:   DateParseValue,
		ParseLiteral: DateParseLiteral,
	})
	// type Song {
	//   name: String!
	//   artist: Artist
	//   duration: Int
	//   release: Date
	//   likes: Int
	// }
	songType := graphql.NewObject(graphql.ObjectConfig{
		Name: "Song",
		Fields: graphql.Fields{
			"name": &graphql.Field{
				Type:    graphql.String,
				Resolve: SongName,
			},
			"duration": &graphql.Field{
				Type:    graphql.Int,
				Resolve: SongDuration,
			},
			"release": &graphql.Field{
				Type:    dateType,
				Resolve: SongRelease,
			},
			"likes": &graphql.Field{
				Type:    graphql.Int,
				Resolve: SongLikes,
			},
		},
	})

	// type Artist {
	//   name: String!
	//   songs: [Song]
	//   origin: [String]
	// }
	artistType := graphql.NewObject(graphql.ObjectConfig{
		Name: "Artist",
		Fields: graphql.Fields{
			"name": &graphql.Field{
				Type:    graphql.String,
				Resolve: ArtistName,
			},
			"songs": &graphql.Field{
				Type:    graphql.NewList(songType),
				Resolve: ArtistSongs,
			},
			"song": &graphql.Field{
				Type: songType,
				Args: graphql.FieldConfigArgument{
					"name": &graphql.ArgumentConfig{
						Type: graphql.NewNonNull(graphql.String),
					},
				},
				Resolve: ArtistSong,
			},
		},
	})

	songType.AddFieldConfig("artist", &graphql.Field{
		Type:    artistType,
		Resolve: SongArtist,
	})

	// type Query {
	//   artist(name: String!): Artist
	//   artists: [Artist]
	// }
	queryType := graphql.NewObject(graphql.ObjectConfig{
		Name: "Query",
		Fields: graphql.Fields{
			"artist": &graphql.Field{
				Type: artistType,
				Args: graphql.FieldConfigArgument{
					"name": &graphql.ArgumentConfig{
						Type: graphql.NewNonNull(graphql.String),
					},
				},
				Resolve: QueryArtist,
			},
			"artists": &graphql.Field{
				Type:    graphql.NewList(artistType),
				Resolve: data.Query.ArtistsGG,
			},
		},
	})

	// type Mutation {
	//   like(artist: String!, song: String!): Song
	// }
	mutationType := graphql.NewObject(graphql.ObjectConfig{
		Name: "Mutation",
		Fields: graphql.Fields{
			"like": &graphql.Field{
				Type: songType,
				Args: graphql.FieldConfigArgument{
					"artist": &graphql.ArgumentConfig{
						Type: graphql.NewNonNull(graphql.String),
					},
					"song": &graphql.ArgumentConfig{
						Type: graphql.NewNonNull(graphql.String),
					},
				},
				Resolve: data.Mutation.LikeGG,
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
	schema, err := buildSchema(setup())
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
