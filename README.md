A technical test for reading movies from themoviedb.org. Files will be commented for explanation reasons where necessary. Additionally, here we will be using our api key directly in the code; in a real world example this would likely be behind our own server for security reasons.


# Project Structure

  

All the source files can be found under `/src`. All Elm files live under `/src/elm`, other assets such as sass files live under `/src/assets`

All tests can be found under `/tests`

All custom webpack loaders can be found under `/loaders`. See the loader file for comments on why we're using a custom loader.

All distribution files can be found under `/dist`

  

# Building from Source

  

* Ensure that [Elm is installed](https://guide.elm-lang.org/install.html). This would be included as an npm dev dependency, however Elm 0.19 has not yet had a release on npm as of yet. If you're new to Elm, feel free to read https://guide.elm-lang.org/ for a quick overview.

* Run `npm i` or `yarn` in the root folder

* Run any of the following in the root folder (feel free to substitute `yarn` for `npm run`)

	* Running `yarn dev` will compile a new unoptimized app.js in dist with elm set to debug mode

	* Running `yarn serve` will start a devserver that watches for changes on localhost:8080 (if available) running an unoptimized debug build

	* Running `yarn prod` will create an optimized production build in dist

  

# Running Tests

  

* Run `npm i` or `yarn` in the root folder if you have not already done so

* Run `npx elm-test` or `yarn elm-test` in the root folder
