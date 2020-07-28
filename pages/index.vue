<template>
  <div>
    <div v-show="selectedMovieShow">
      <h2>Comparison Results</h2>
      <h3>Chosen movie</h3>
      <v-container class="movie-container-res" fluid="fluid">
        <v-card :key="selectedMovie + Math.random()" class="darken-2 mov-card-res">
          <v-container fluid grid-list-lg>
            <v-layout row>
              <v-flex xs7>
                <div>
                  <div class="headline">
                    {{ selectedMovie.title }}
                  </div>
                  <div>Director: {{ selectedMovie.director }}</div>
                  <div>Genres: {{ selectedMovie.genres }}</div>
                  <div>Year: {{ selectedMovie.year }}</div>
                  <div>Rating: {{ selectedMovie.rating }}</div>
                </div>
              </v-flex>
              <v-flex xs5>
                <v-img
                  :src="selectedMovie.poster"
                  height="125px"
                  contain
                />
              </v-flex>
            </v-layout>
          </v-container>
          <v-card-actions>
            <v-btn text class="orange--text" @click.native="redirectURL(selectedMovie.url)">
              IMdB
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-container>

      <v-container class="movie-container-res" fluid="fluid">
        <v-card v-for="movie in compRes" :key="movie + Math.random()" class="darken-2 mov-card-res">
          <v-container fluid grid-list-lg>
            <v-layout row>
              <v-flex xs7>
                <div>
                  <div class="headline">
                    {{ movie.title }}
                  </div>
                  <div>Director: {{ movie.director }}</div>
                  <div>Genres: {{ movie.genres }}</div>
                  <div>Year: {{ movie.year }}</div>
                  <div>Rating: {{ movie.rating }}</div>
                </div>
              </v-flex>
              <v-flex xs5>
                <v-img
                  :src="movie.poster"
                  height="125px"
                  contain
                />
              </v-flex>
            </v-layout>
          </v-container>
          <v-card-actions>
            <v-btn text class="orange--text" @click.native="redirectURL(movie.url)">
              IMdB
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-container>
    </div>

    <v-text-field v-model="inputMessage" label="Movie filter" @input="setPagination" />

    <h2>Movie List</h2>

    <v-container class="movie-container" fluid="fluid">
      <v-card v-for="movie in pagedItems" :key="movie + Math.random()" class="darken-2 mov-card">
        <v-container fluid grid-list-lg>
          <v-layout row>
            <v-flex xs7>
              <div>
                <div class="headline">
                  {{ movie.title }}
                </div>
                <div>Director: {{ movie.director }}</div>
                <div>Genres: {{ movie.genres }}</div>
                <div>Year: {{ movie.year }}</div>
                <div>Rating: {{ movie.rating }}</div>
              </div>
            </v-flex>
            <v-flex xs5>
              <v-img
                :src="movie.poster"
                height="125px"
                contain
              />
            </v-flex>
          </v-layout>
        </v-container>
        <v-card-actions>
          <v-btn text class="orange--text" @click.native="redirectURL(movie.url)">
            IMdB
          </v-btn>
          <v-btn text class="orange--text" @click.native="calcRecommendtion(movie)">
            ALS
          </v-btn>
          <v-btn text class="orange--text" @click.native="calcRecommendtionD2V(movie)">
            Doc2Vec
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-container>

    <div id="pagination" class="text-xs-center">
      <v-pagination
        v-model="page"
        :length="Math.floor(movies.length/100) + 1"
        :disabled="disablePagination"
      />
    </div>

    <v-snackbar
      v-model="snackbar"
      :timeout="-1"
    >
      Calculating recommendations
      <v-btn text class="pink--text" @click.native="snackbar = false">
        Close
      </v-btn>
    </v-snackbar>
  </div>
</template>

<script>
export default {
  name: 'Index',
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
      disablePagination: false
    }
  },
  computed: {
    pagedItems () {
      return this.movies.filter((item, idx) => {
        if (this.inputMessage !== '') {
          return item.title.toLowerCase().includes(this.inputMessage.toLowerCase())
        }
        const min = (this.page * 100) - 100
        const max = (this.page * 100) - 1
        return (idx > min && idx <= max)
      })
    }
  },
  mounted () {
    this.getMovieList()
  },
  methods: {
    setPagination (input) {
      this.disablePagination = input !== ''
    },
    getMovieList () {
      fetch('/movies')
        .then((r) => {
          return r.text()
        }).then((rr) => {
          this.movies = JSON.parse(rr)
        })
    },
    calcRecommendtion (movie) {
      this.selectedMovie = movie
      this.selectedMovieShow = true
      fetch('/recommend/' + movie.title)
        .then((r) => {
          return r.text()
        }).then((rr) => {
          const movs = []
          for (const m of JSON.parse(rr)) {
            movs.push(m)
          }
          this.compRes = movs
          this.snackbar = false
        })
      window.scrollTo(0, 0)
      this.snackbar = true
    },
    redirectURL (movie) {
      location.href = movie
    },
    calcRecommendtionD2V (movie) {
      this.selectedMovie = movie
      this.selectedMovieShow = true
      fetch('/recommend-d2v/' + movie.title)
        .then((r) => {
          return r.json()
        }).then((r) => {
          const movs = []
          for (const m of r) {
            movs.push(this.searchMovie(m[0]))
          }
          this.snackbar = false
          this.compRes = movs
        })
      window.scrollTo(0, 0)
      this.snackbar = true
    },
    searchMovie (movie) {
      for (const m of this.movies) {
        if (m.title === movie) {
          return m
        }
      }
    },
    checkIndex (idx) {
      if (this.inputMessage !== '') {
        return true
      }
      const min = (this.page * 100) - 100
      const max = (this.page * 100) - 1
      return (idx > min && idx < max)
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

#pagination {
    padding-bottom: 10px;
}
</style>
