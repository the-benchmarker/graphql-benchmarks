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
////////////////////////////////////////////////////////////////////////////////
// Start of GraphQL package neutral type definitions.

func setupSongs() *Schema {
	fazerdaze := Artist{Name: "Fazerdaze", Origin: []string{"Morningside", "Auckland", "New Zealand"}}
	may5 := &Date{Year: 2017, Month: 5, Day: 5}
	nov2 := &Date{Year: 2015, Month: 11, Day: 2}
	fazerdaze.Songs = SongList{
		{Name: "Jennifer", Artist: &fazerdaze, Duration: 240, Release: may5},
		{Name: "Lucky Girl", Artist: &fazerdaze, Duration: 170, Release: may5},
		{Name: "Friends", Artist: &fazerdaze, Duration: 194, Release: may5},
		{Name: "Reel", Artist: &fazerdaze, Duration: 193, Release: nov2},
	}

	boys := Artist{Name: "Viagra Boys", Origin: []string{"Stockholm", "Sweden"}}
	sep28 := &Date{Year: 2018, Month: 11, Day: 2}
	boys.Songs = SongList{
		{Name: "Down In The Basement", Artist: &boys, Duration: 216, Release: sep28},
		{Name: "Frogstrap", Artist: &boys, Duration: 195, Release: sep28},
		{Name: "Worms", Artist: &boys, Duration: 208, Release: sep28},
		{Name: "Amphetanarchy", Artist: &boys, Duration: 346, Release: sep28},
	}

	query := Query{
		Title:   "Songs",
		Artists: ArtistList{&fazerdaze, &boys},
	}
	return &Schema{
		Query:    &query,
		Mutation: &Mutation{query: &query},
	}
}

// Schema represents the top level of a GraphQL data/resolver graph.
type Schema struct {
	Query    *Query
	Mutation *Mutation
}

// Query represents the query node in a data/resolver graph.
type Query struct {
	Title   string
	Artists ArtistList
}

// Mutation represents the query node in a data/resolver graph.
type Mutation struct {
	query *Query // Query is the data store for this example
}

// Likes increments likes attribute the song of the artist specified.
func (m *Mutation) Likes(artist, song string) *Song {
	if a := m.query.Artists.GetByName(artist); a != nil {
		if s := a.Songs.GetByName(song); s != nil {
			s.Likes++
			return s
		}
	}
	return nil
}

// Artist returns the artist in the list with the specified name.
func (q *Query) Artist(name string) *Artist {
	return q.Artists.GetByName(name)
}

// Artist represents the GraphQL Artist.
type Artist struct {
	Name   string
	Songs  SongList
	Origin []string
}

// Song represents the GraphQL Song.
type Song struct {
	Name     string
	Artist   *Artist
	Duration int
	Release  *Date
	Likes    int
}

// ArtistList is a list of Artists. It exists to allow list members to be
// ordered but still implement map like behavionr (not yet implemented).
type ArtistList []*Artist

// Len of the list.
func (al ArtistList) Len() int {
	return len(al)
}

// Nth element in the list.
func (al ArtistList) Nth(i int) interface{} {
	return al[i]
}

// GetByName retrieves the element with the specified name.
func (al ArtistList) GetByName(name string) *Artist {
	for _, a := range al {
		if a.Name == name {
			return a
		}
	}
	return nil
}

// SongList is a list of Songs. It exists to allow list members to be
// ordered but still implement map like behavionr (not yet implemented).
type SongList []*Song

// Len of the list.
func (sl SongList) Len() int {
	return len(sl)
}

// Nth element in the list.
func (sl SongList) Nth(i int) interface{} {
	return sl[i]
}

// GetByName retrieves the element with the specified name.
func (sl SongList) GetByName(name string) *Song {
	for _, s := range sl {
		if s.Name == name {
			return s
		}
	}
	return nil
}

// Date represents a date with year, month, and day of the month.
type Date struct {
	Year  int
	Month int
	Day   int
}

// DateFromString parses a string in the format YYY-MM-DD into a Date
// instance.
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

// String returns a YYYY-MM-DD formatted string representation of the Date.
func (d *Date) String() string {
	return fmt.Sprintf("%04d-%02d-%02d", d.Year, d.Month, d.Day)
}

// End of GraphQL package neutral type definitions.
////////////////////////////////////////////////////////////////////////////////

// Now the framework specific code.

func (q *Query) ArtistsGG(params graphql.ResolveParams) (interface{}, error) {
	return q.Artists, nil
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
	return m.Likes(artist, song), nil
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
	return q.Artists.GetByName(name), nil
}

func QueryArtists(params graphql.ResolveParams) (interface{}, error) {
	q, ok := params.Source.(*Query)
	if !ok {
		return nil, fmt.Errorf("Schema.query resolve failed XX (%T)", params.Source)
	}
	return q.Artists, nil
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
	return a.Songs.GetByName(name), nil
}

func ArtistSongs(params graphql.ResolveParams) (interface{}, error) {
	a, ok := params.Source.(*Artist)
	if !ok {
		return nil, fmt.Errorf("Query.artist resolve failed (%T)", params.Source)
	}
	return a.Songs, nil
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
	schema, err := buildSchema(setupSongs())
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
