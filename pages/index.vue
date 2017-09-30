<template>
  <v-app>

    <h1 class="id-wrapper">
      <object id="logo" data="hot-pepper.svg" type="image/svg+xml"></object>
      Movie Pepper
      <object id="logo" data="hot-pepper.svg" type="image/svg+xml"></object>
    </h1>

    <div v-show="selectedMovieShow">
      <h2>Comparison Results</h2>
      <h3>Chosen movie</h3>
      <v-container class="movie-container-res" fluid="fluid">

        <v-card class="darken-2 mov-card-res" :key="selectedMovie + Math.random()">
          <v-container fluid grid-list-lg>
            <v-layout row>
              <v-flex xs7>
                <div>
                  <div class="headline">{{selectedMovie.title}}</div>
                  <div>Director: {{selectedMovie.director}}</div>
                  <div>Genres: {{selectedMovie.genres}}</div>
                  <div>Year: {{selectedMovie.year}}</div>
                  <div>Rating: {{selectedMovie.rating}}</div>
                </div>
              </v-flex>
              <v-flex xs5>
                <v-card-media
                  :src="selectedMovie.poster"
                  height="125px"
                  contain
                  ></v-card-media>
              </v-flex>
            </v-layout>
          </v-container>
          <v-card-actions>
            <v-btn flat class="orange--text" @click.native='redirectURL(selectedMovie.url)'>IMdB</v-btn>
          </v-card-actions>
        </v-card>
      </v-container>

      <v-container class="movie-container-res" fluid="fluid">
        <v-card class="darken-2 mov-card-res" v-for="(movie, index) in compRes" :key="movie + Math.random()">
          <v-container fluid grid-list-lg>
            <v-layout row>
              <v-flex xs7>
                <div>
                  <div class="headline">{{movie.title}}</div>
                  <div>Director: {{movie.director}}</div>
                  <div>Genres: {{movie.genres}}</div>
                  <div>Year: {{movie.year}}</div>
                  <div>Rating: {{movie.rating}}</div>
                </div>
              </v-flex>
              <v-flex xs5>
                <v-card-media
                  :src="movie.poster"
                  height="125px"
                  contain
                  ></v-card-media>
              </v-flex>
            </v-layout>
          </v-container>
          <v-card-actions>
            <v-btn flat class="orange--text" @click.native='redirectURL(movie.url)'>IMdB</v-btn>
          </v-card-actions>
        </v-card>
      </v-container>

    </div>

    <h2>Movie List</h2>
    <v-text-field label='Movie filter' v-model="inputMessage"></v-text-field>

    <v-container class="movie-container" fluid="fluid">

      <v-card class="darken-2 mov-card" v-for="(movie, index) in filteredItems" :key="movie + Math.random()" v-if="checkIndex(index)">
        <v-container fluid grid-list-lg>
          <v-layout row>
            <v-flex xs7>
              <div>
                <div class="headline">{{movie.title}}</div>
                <div>Director: {{movie.director}}</div>
                <div>Genres: {{movie.genres}}</div>
                <div>Year: {{movie.year}}</div>
                <div>Rating: {{movie.rating}}</div>
              </div>
            </v-flex>
            <v-flex xs5>
              <v-card-media
                :src="movie.poster"
                height="125px"
                contain
                ></v-card-media>
            </v-flex>
          </v-layout>
        </v-container>
        <v-card-actions>
          <v-btn flat class="orange--text" @click.native='redirectURL(movie.url)'>IMdB</v-btn>
          <v-btn flat class="orange--text" @click.native="calcRecommendtion(movie)">ALS</v-btn>
          <v-btn flat class="orange--text" @click.native="calcRecommendtionD2V(movie)">Doc2Vec</v-btn>
        </v-card-actions>
      </v-card>
    </v-container>

    <div id="pagination" class="text-xs-center">
      <v-pagination v-bind:length.number="Math.floor(movies.length/100) + 1" v-model="page" v-bind:disabled="pagination"></v-pagination>
    </div>

    <v-snackbar
      :timeout="0"
      v-model="snackbar">
      Calculating recommendations
      <v-btn flat class="pink--text" @click.native="snackbar = false">Close</v-btn>
    </v-snackbar>

  </v-app>
</template>

<script>
/* @flow */
export default {
  name: 'test',
  mounted () {
    this.getMovieList()
  },
  data () {
    return {
      snackbar: false,
      msg: 'HugoFS - Movie Recommender',
      movies: [],
      compRes: [],
      inputMessage: '',
      selectedMovie: {},
      selectedMovieShow: false,
      show: {},
      page: 1,
      lastPage: 1,
      pagination: true
    }
  },
  methods: {
    getMovieList: function () {
      fetch('/movies')
        .then((r) => {
          return r.text()
        }).then((rr) => {
          this.movies = JSON.parse(rr)
        })
    },
    calcRecommendtion: function (movie: Object) {
      this.selectedMovie = movie
      this.selectedMovieShow = true
      fetch('/recommend/' + movie.title)
        .then((r) => {
          return r.text()
        }).then((rr) => {
          let movs = []
          for (const m of JSON.parse(rr)) {
            movs.push(m)
          }
          this.compRes = movs
          this.snackbar = false
        })
      window.scrollTo(0, 0)
      this.snackbar = true
    },
    redirectURL: function (movie: string) {
      location.href = movie
    },
    calcRecommendtionD2V: function (movie: Object) {
      this.selectedMovie = movie
      this.selectedMovieShow = true
      fetch('/recommend-d2v/' + movie.title)
        .then((r) => {
          return r.json()
        }).then((r) => {
          let movs = []
          for (const m of r) {
            movs.push(this.searchMovie(m[0]))
          }
          this.snackbar = false
          this.compRes = movs
        })
      window.scrollTo(0, 0)
      this.snackbar = true
    },
    searchMovie (movie: string) {
      for (const m of this.movies) {
        if (m.title === movie) {
          return m
        }
      }
    },
    checkIndex (idx) {
      if (this.inputMessage !== '') return true
      let min = (this.page * 100) - 100
      let max = (this.page * 100) - 1
      return (idx > min && idx < max)
    }
  },
  computed: {
    filteredItems () {
      this.page = 1
      this.pagination = this.inputMessage !== ''

      return this.movies.filter(item => {
        return item.title.toLowerCase().indexOf(this.inputMessage.toLowerCase()) > -1
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}

a {
  color: #42b983;
}

.id-wrapper {
  text-align: center;
  padding-top: 10px;
}

.movie-container-res {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  justify-items: stretch;
  width: 100%;
}

.movie-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  justify-items: stretch;
  width: 100%;
}

.mov-card-res {
  padding: 1px;
  margin: 5px;
  cursor: default;
}

.mov-card {
  padding: 1px;
  margin: 5px;
  cursor: default;
}

.snack {
  margin: 5px;
}

#logo {
  height: 1em;
  margin: 3px;
}

#pagination {
    padding-bottom: 10px;
}
</style>
