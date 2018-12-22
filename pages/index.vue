<template>
  <VApp>
    <h1 class="id-wrapper">
      <object
        id="logo"
        data="hot-pepper.svg"
        type="image/svg+xml"
      />
      Movie Pepper
      <object
        id="logo"
        data="hot-pepper.svg"
        type="image/svg+xml"
      />
    </h1>

    <div v-show="selectedMovieShow">
      <h2>Comparison Results</h2>
      <h3>Chosen movie</h3>
      <VContainer
        class="movie-container-res"
        fluid="fluid"
      >
        <VCard
          :key="selectedMovie + Math.random()"
          class="darken-2 mov-card-res"
        >
          <VContainer
            fluid
            grid-list-lg
          >
            <VLayout row>
              <VFlex xs7>
                <div>
                  <div class="headline">
                    {{ selectedMovie.title }}
                  </div>
                  <div>Director: {{ selectedMovie.director }}</div>
                  <div>Genres: {{ selectedMovie.genres }}</div>
                  <div>Year: {{ selectedMovie.year }}</div>
                  <div>Rating: {{ selectedMovie.rating }}</div>
                </div>
              </VFlex>
              <VFlex xs5>
                <VCardMedia
                  :src="selectedMovie.poster"
                  height="125px"
                  contain
                />
              </VFlex>
            </VLayout>
          </VContainer>
          <VCardActions>
            <VBtn
              flat
              class="orange--text"
              @click.native="redirectURL(selectedMovie.url)"
            >
              IMdB
            </VBtn>
          </VCardActions>
        </VCard>
      </VContainer>

      <VContainer
        class="movie-container-res"
        fluid="fluid"
      >
        <VCard
          v-for="(movie) in compRes"
          :key="movie + Math.random()"
          class="darken-2 mov-card-res"
        >
          <VContainer
            fluid
            grid-list-lg
          >
            <VLayout row>
              <VFlex xs7>
                <div>
                  <div class="headline">
                    {{ movie.title }}
                  </div>
                  <div>Director: {{ movie.director }}</div>
                  <div>Genres: {{ movie.genres }}</div>
                  <div>Year: {{ movie.year }}</div>
                  <div>Rating: {{ movie.rating }}</div>
                </div>
              </VFlex>
              <VFlex xs5>
                <VCardMedia
                  :src="movie.poster"
                  height="125px"
                  contain
                />
              </VFlex>
            </VLayout>
          </VContainer>
          <VCardActions>
            <VBtn
              flat
              class="orange--text"
              @click.native="redirectURL(movie.url)"
            >
              IMdB
            </VBtn>
          </VCardActions>
        </VCard>
      </VContainer>
    </div>

    <h2>Movie List</h2>
    <VTextField
      v-model="inputMessage"
      label="Movie filter"
    />

    <VContainer
      class="movie-container"
      fluid="fluid"
    >
      <VCard
        v-for="(movie, index) in filteredItems"
        v-if="checkIndex(index)"
        :key="movie + Math.random()"
        class="darken-2 mov-card"
      >
        <VContainer
          fluid
          grid-list-lg
        >
          <VLayout row>
            <VFlex xs7>
              <div>
                <div class="headline">
                  {{ movie.title }}
                </div>
                <div>Director: {{ movie.director }}</div>
                <div>Genres: {{ movie.genres }}</div>
                <div>Year: {{ movie.year }}</div>
                <div>Rating: {{ movie.rating }}</div>
              </div>
            </VFlex>
            <VFlex xs5>
              <VCardMedia
                :src="movie.poster"
                height="125px"
                contain
              />
            </VFlex>
          </VLayout>
        </VContainer>
        <VCardActions>
          <VBtn
            flat
            class="orange--text"
            @click.native="redirectURL(movie.url)"
          >
            IMdB
          </VBtn>
          <VBtn
            flat
            class="orange--text"
            @click.native="calcRecommendtion(movie)"
          >
            ALS
          </VBtn>
          <VBtn
            flat
            class="orange--text"
            @click.native="calcRecommendtionD2V(movie)"
          >
            Doc2Vec
          </VBtn>
        </VCardActions>
      </VCard>
    </VContainer>

    <div
      id="pagination"
      class="text-xs-center"
    >
      <VPagination
        v-model="page"
        :length="Math.floor(movies.length/100) + 1"
        :disabled="pagination"
      />
    </div>

    <VSnackbar
      v-model="snackbar"
      :timeout="0"
    >
      Calculating recommendations
      <VBtn
        flat
        class="pink--text"
        @click.native="snackbar = false"
      >
        Close
      </VBtn>
    </VSnackbar>
  </VApp>
</template>

<script>
/* @flow */
export default {
  name: 'Test',
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
  computed: {
    filteredItems () {
      this.page = 1 // eslint-disable-line
      this.pagination = this.inputMessage !== '' // eslint-disable-line

      return this.movies.filter(item => {
        return item.title.toLowerCase().indexOf(this.inputMessage.toLowerCase()) > -1
      })
    }
  },
  mounted () {
    this.getMovieList()
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
    calcRecommendtion: function (movie) {
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
    redirectURL: function (movie) {
      location.href = movie
    },
    calcRecommendtionD2V: function (movie) {
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
    searchMovie (movie) {
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
