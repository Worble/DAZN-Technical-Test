'use strict';

import ElmRuntime from './elm/Main.elm';
import './assets/sass/styles.scss';

(function () {
    var node = document.getElementById('elm');
    var app = ElmRuntime.Elm.Main.init({
        node: node
    });
})();