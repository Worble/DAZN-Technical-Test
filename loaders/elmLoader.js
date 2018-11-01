/* 
    We're using a custom loader here because 
    1. At the initial time of writing, the elm-loader package wasn't updated for elm 0.19 
    2. We can get some gains in filesize using a custom minifier that does what would be
       unsafe optimisations in regular JS code.
*/

var ElmCompiler = require('node-elm-compiler');
var UglifyJS = require('uglify-js');

module.exports = function elmLoader(content, map, meta) {
    var callback = this.async();

    //parsing loader arguments and setting appropriate options
    var optimize = this.query.optimize;
    var opts = {};
    if (optimize) {
        opts.optimize = true;
    } else {
        opts.debug = true;
    }

    var addDependency = this.addDependency;
    /* Here we're finding all the elm dependencies so that the watcher 
    knows to refresh when any of these change, not just Main.elm */
    ElmCompiler.findAllDependencies(this.resourcePath).then(function (dependencies) {
        dependencies.forEach(function (dependency) {
            addDependency(dependency);
        });
    });

    //compiles the Elm file and returns it as a js string
    ElmCompiler.compileToString([this.resourcePath], opts).then(function (data) {
        if (optimize) {
            var result = minify(data);
            if (result.error) {
                console.log(result.error);
                data = "";
            } else {
                data = result.code;
            }
        };
        callback(null, data, map, meta);
    }).catch(function (err) {
        //logs any errors to the console but does not stop the watcher if it's running
        console.log(err);
        callback(null, "", map, meta);
    });
}

//our minify function, this would be unsafe on regular JS code, but ELM gives us certain guarantees.
function minify(jsString) {
    const options = {
        compress: {
            pure_funcs: ['F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9'],
            keep_fargs: false,
            pure_getters: true,
            unsafe_comps: true,
            unsafe: true
        },
    };
    return UglifyJS.minify(jsString, options);
}